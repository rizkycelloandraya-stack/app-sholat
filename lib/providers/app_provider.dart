import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/prayer_schedule.dart';
import '../models/documentation_item.dart';
import '../services/prayer_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();
  DailyPrayerSchedule? _prayerSchedule;
  List<DocumentationItem> _history = [];

  double _latitude = LocationService.defaultLatitude;
  double _longitude = LocationService.defaultLongitude;
  String _locationName = LocationService.defaultLocationName;

  bool _isLoading = true;
  bool _isLocationRefreshing = false;
  Timer? _countdownTimer;
  DateTime _lastCalculatedDate = DateTime.now();

  AppSettings get settings => _settings;
  DailyPrayerSchedule? get prayerSchedule => _prayerSchedule;
  List<DocumentationItem> get history => _history;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get locationName => _locationName;
  bool get isLoading => _isLoading;
  bool get isLocationRefreshing => _isLocationRefreshing;
  ThemeMode get themeMode => _settings.themeMode;

  /// Initialize application data, location, schedule, and timer
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // 1. Load persisted settings
    _settings = await StorageService.loadSettings();

    // 2. Load history items
    _history = await StorageService.loadHistory();

    // 3. Initialize notification service
    await NotificationService.initialize();

    // 4. Fetch initial location
    await refreshLocation(silent: true);

    // 5. Calculate prayer times
    _recalculatePrayerSchedule();

    // 6. Start 1-second periodic countdown timer
    _startCountdownTimer();

    _isLoading = false;
    notifyListeners();
  }

  /// Start real-time ticking countdown timer
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      // Check if date changed (midnight crossover)
      if (now.day != _lastCalculatedDate.day ||
          now.month != _lastCalculatedDate.month ||
          now.year != _lastCalculatedDate.year) {
        _lastCalculatedDate = now;
        _recalculatePrayerSchedule();
        return;
      }

      // Update countdown
      if (_prayerSchedule != null) {
        _recalculatePrayerSchedule(silentNotifications: true);
      }
    });
  }

  /// Recalculate prayer times and refresh schedule state
  void _recalculatePrayerSchedule({bool silentNotifications = false}) {
    final now = DateTime.now();
    _prayerSchedule = PrayerService.calculateDailySchedule(
      date: now,
      latitude: _latitude,
      longitude: _longitude,
      locationName: _locationName,
      calculationMethod: _settings.calculationMethod,
      madhhab: _settings.madhhab,
    );

    if (!silentNotifications && _prayerSchedule != null) {
      NotificationService.reschedulePrayerNotifications(
        schedule: _prayerSchedule!,
        settings: _settings,
      );
    }

    notifyListeners();
  }

  /// Refresh GPS location and update schedule
  Future<void> refreshLocation({bool silent = false}) async {
    if (!silent) {
      _isLocationRefreshing = true;
      notifyListeners();
    }

    final locResult = await LocationService.getCurrentLocation();
    _latitude = locResult.latitude;
    _longitude = locResult.longitude;
    _locationName = locResult.readableName;

    _recalculatePrayerSchedule();

    if (!silent) {
      _isLocationRefreshing = false;
      notifyListeners();
    }
  }

  /// Update and persist settings
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await StorageService.saveSettings(_settings);

    // Recalculate schedule & reschedule notifications
    _recalculatePrayerSchedule();
  }

  /// Reload history from storage
  Future<void> refreshHistory() async {
    _history = await StorageService.loadHistory();
    notifyListeners();
  }

  /// Delete history item
  Future<void> deleteHistoryItem(String id) async {
    await StorageService.deleteDocumentationItem(id);
    await refreshHistory();
  }

  /// Update an existing history item
  Future<void> updateHistoryItem(DocumentationItem item) async {
    await StorageService.updateDocumentationItem(item);
    await refreshHistory();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
