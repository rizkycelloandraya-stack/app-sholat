import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/app_settings.dart';
import '../models/prayer_schedule.dart';
import '../utils/permission_utils.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize local notification plugin and timezones
  static Future<void> initialize() async {
    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          // Handle tap if needed
        },
      );

      _isInitialized = true;
    } catch (_) {}
  }

  /// Request permissions for notifications
  static Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    await initialize();
    return await PermissionUtils.requestNotificationPermissions(
        _notificationsPlugin);
  }

  /// Reschedule all prayer notifications based on schedule and settings
  static Future<void> reschedulePrayerNotifications({
    required DailyPrayerSchedule schedule,
    required AppSettings settings,
  }) async {
    if (kIsWeb) return;

    await initialize();

    try {
      // Cancel all existing scheduled notifications
      await _notificationsPlugin.cancelAll();

      final offset = Duration(minutes: settings.reminderMinutesBefore);
      final now = DateTime.now();

      final prayerConfig = [
        (PrayerType.subuh, settings.alarmSubuh, 101),
        (PrayerType.dzuhur, settings.alarmDzuhur, 102),
        (PrayerType.ashar, settings.alarmAshar, 103),
        (PrayerType.maghrib, settings.alarmMaghrib, 104),
        (PrayerType.isya, settings.alarmIsya, 105),
      ];

      for (final (type, isEnabled, id) in prayerConfig) {
        if (!isEnabled) continue;

        final prayerItem = schedule.getPrayer(type);
        if (prayerItem == null) continue;

        final scheduledTime = prayerItem.time.subtract(offset);

        // Only schedule if it's in the future
        if (scheduledTime.isAfter(now)) {
          await _scheduleSingleNotification(
            id: id,
            title: 'Waktu Sholat ${prayerItem.name}',
            body: settings.reminderMinutesBefore > 0
                ? '${settings.reminderMinutesBefore} menit menuju waktu sholat ${prayerItem.name} (${prayerItem.time.hour.toString().padLeft(2, '0')}:${prayerItem.time.minute.toString().padLeft(2, '0')})'
                : 'Telah masuk waktu sholat ${prayerItem.name} untuk wilayah ${schedule.locationName}',
            scheduledDate: scheduledTime,
            sound: settings.soundEnabled,
            vibrate: settings.vibrationEnabled,
          );
        }
      }
    } catch (_) {}
  }

  static Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required bool sound,
    required bool vibrate,
  }) async {
    try {
      final tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);

      final androidDetails = AndroidNotificationDetails(
        'sholat_sigma_channel',
        'Jadwal Sholat Sigma',
        channelDescription: 'Pengingat waktu sholat lokal untuk kelas',
        importance: Importance.high,
        priority: Priority.high,
        playSound: sound,
        enableVibration: vibrate,
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: sound,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduled,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }
}
