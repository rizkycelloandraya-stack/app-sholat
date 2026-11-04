import 'package:flutter/material.dart';
import '../models/photo_capture.dart';
import '../models/documentation_item.dart';
import '../models/prayer_schedule.dart';
import '../models/app_settings.dart';
import '../services/collage_service.dart';
import '../services/storage_service.dart';
import '../services/sharing_service.dart';
import '../services/location_service.dart';

enum DocWorkflowState {
  ready,
  capturing,
  processing,
  completed,
  error,
}

class DocumentationProvider extends ChangeNotifier {
  // Slot 0 = Subuh, Slot 1 = Maghrib, Slot 2 = Isya
  final List<PhotoCapture?> _slots = [null, null, null];
  DocWorkflowState _state = DocWorkflowState.ready;
  String? _errorMessage;
  DocumentationItem? _lastGeneratedItem;
  String _studentName = '';
  String _locationName = '';
  String _editingTitle = 'Dokumentasi Sholat Subuh, Maghrib, Isya';
  String _editingDescription = '';

  List<PhotoCapture> get captures => _slots.whereType<PhotoCapture>().toList();
  List<PhotoCapture?> get slots => List.unmodifiable(_slots);
  int get currentCount => _slots.where((s) => s != null).length;
  bool get isAllSlotsFilled => _slots.every((s) => s != null);

  DocWorkflowState get state => _state;
  String? get errorMessage => _errorMessage;
  DocumentationItem? get lastGeneratedItem => _lastGeneratedItem;
  String get studentName => _studentName;
  String get locationName => _locationName;
  String get editingTitle => _editingTitle;
  String get editingDescription => _editingDescription;

  PhotoCapture? get subuhPhoto => _slots[0];
  PhotoCapture? get maghribPhoto => _slots[1];
  PhotoCapture? get isyaPhoto => _slots[2];

  /// Initialize provider with default values, stored student name, and saved draft slots
  Future<void> init(String defaultLocation) async {
    _state = DocWorkflowState.ready;
    _errorMessage = null;

    final savedName = await StorageService.loadDefaultStudentName();
    if (savedName.isNotEmpty) {
      _studentName = savedName;
    }

    final draft = await StorageService.loadDraftSession();
    if (draft != null) {
      final loadedSlots = draft['slots'] as List<PhotoCapture?>?;
      if (loadedSlots != null && loadedSlots.length == 3) {
        _slots[0] = loadedSlots[0];
        _slots[1] = loadedSlots[1];
        _slots[2] = loadedSlots[2];
      }
      final draftName = (draft['studentName'] as String? ?? '').trim();
      if (draftName.isNotEmpty) {
        _studentName = draftName;
      }
      final draftLocation = (draft['locationName'] as String? ?? '').trim();
      _locationName = draftLocation.isNotEmpty ? draftLocation : defaultLocation;
      _editingDescription = draft['description'] as String? ?? '';
    } else {
      if (_locationName.isEmpty) {
        _locationName = defaultLocation;
      }
    }

    notifyListeners();
  }

  Future<void> _persistDraft() async {
    await StorageService.saveDraftSession(
      slots: _slots,
      studentName: _studentName,
      locationName: _locationName,
      description: _editingDescription,
    );
  }

  void setStudentName(String val) {
    _studentName = val;
    notifyListeners();
    _persistDraft();
  }

  void setLocationName(String val) {
    _locationName = val;
    notifyListeners();
    _persistDraft();
  }

  void setEditingTitle(String val) {
    _editingTitle = val;
    notifyListeners();
  }

  void setEditingDescription(String val) {
    _editingDescription = val;
    notifyListeners();
    _persistDraft();
  }

  /// Reset capture state for a fresh documentation session
  Future<void> reset() async {
    _slots[0] = null;
    _slots[1] = null;
    _slots[2] = null;
    _state = DocWorkflowState.ready;
    _errorMessage = null;
    _lastGeneratedItem = null;
    _editingDescription = '';
    notifyListeners();
    await StorageService.clearDraftSession();
  }

  /// Set photo for a specific prayer slot (0 = Subuh, 1 = Maghrib, 2 = Isya)
  /// Automatically copies photo to permanent storage so it survives RAM eviction.
  Future<void> setPhotoForSlot(int slotIndex, String filePath, {DateTime? timestamp}) async {
    if (slotIndex < 0 || slotIndex > 2) return;

    final captureTime = timestamp ?? DateTime.now();
    final prayerNames = ['Subuh', 'Maghrib', 'Isya'];

    final permanentPath = await StorageService.persistDraftSlotPhoto(
      slotIndex,
      filePath,
    );

    _slots[slotIndex] = PhotoCapture(
      shotIndex: slotIndex + 1,
      filePath: permanentPath,
      timestamp: captureTime,
      prayerName: prayerNames[slotIndex],
    );

    notifyListeners();
    await _persistDraft();
  }

  /// Remove photo from a specific slot and delete its file from storage
  Future<void> removePhotoForSlot(int slotIndex) async {
    if (slotIndex >= 0 && slotIndex <= 2) {
      final oldPath = _slots[slotIndex]?.filePath;
      _slots[slotIndex] = null;
      notifyListeners();
      await StorageService.deleteDraftSlotPhoto(slotIndex, oldPath);
      await _persistDraft();
    }
  }

  /// Add a captured photo to the next available slot in order (Subuh -> Maghrib -> Isya)
  Future<bool> addPhotoCapture(String filePath) async {
    for (int i = 0; i < 3; i++) {
      if (_slots[i] == null) {
        await setPhotoForSlot(i, filePath);
        return isAllSlotsFilled;
      }
    }
    return true;
  }

  /// Retake the most recent photo capture
  Future<void> retakeLastPhoto() async {
    for (int i = 2; i >= 0; i--) {
      if (_slots[i] != null) {
        final oldPath = _slots[i]?.filePath;
        _slots[i] = null;
        notifyListeners();
        await StorageService.deleteDraftSlotPhoto(i, oldPath);
        await _persistDraft();
        break;
      }
    }
  }

  /// Process the 3 prayer photos (Subuh, Maghrib, Isya) into high quality collage & save locally
  Future<DocumentationItem?> processAndGenerateCollage({
    required DailyPrayerSchedule? prayerSchedule,
    required String locationName,
    required double latitude,
    required double longitude,
    required AppSettings settings,
    String? customStudentName,
    String? customDescription,
  }) async {
    if (!isAllSlotsFilled) {
      _errorMessage = 'Harap lengkapi ketiga foto (Sholat Subuh, Maghrib, dan Isya).';
      _state = DocWorkflowState.error;
      notifyListeners();
      return null;
    }

    _state = DocWorkflowState.processing;
    _errorMessage = null;
    notifyListeners();

    try {
      final finalStudentName = customStudentName?.trim().isNotEmpty == true
          ? customStudentName!.trim()
          : _studentName.trim();
      final finalLocation = _locationName.trim().isNotEmpty
          ? _locationName.trim()
          : locationName;
      final finalDescription = customDescription?.trim() ?? _editingDescription.trim();

      // Persist student name for future use
      if (finalStudentName.isNotEmpty) {
        await StorageService.saveDefaultStudentName(finalStudentName);
      }

      final capturesList = [
        _slots[0]!,
        _slots[1]!,
        _slots[2]!,
      ];

      final primaryTimestamp = capturesList.first.timestamp;
      const title = 'Dokumentasi Sholat Subuh, Maghrib, Isya';

      // Obtain detailed address for GPS Geo-tagging watermark
      final addressDetails = await LocationService.getDetailedAddress(
        latitude: latitude,
        longitude: longitude,
      );
      final districtProvince = addressDetails['districtProvince'] ?? finalLocation;
      final fullAddress = addressDetails['fullAddress'] ?? finalLocation;

      // Generate composite collage with exact GPS Geo-Tagging Camera watermark
      final collagePath = await CollageService.generateCollage(
        captures: capturesList,
        studentName: finalStudentName,
        activityTitle: title,
        description: finalDescription,
        documentationTimestamp: primaryTimestamp,
        locationName: finalLocation,
        districtProvince: districtProvince,
        fullAddress: fullAddress,
        latitude: latitude,
        longitude: longitude,
      );

      // Persist original photos if setting is enabled
      List<String> originalPaths = [];
      if (settings.saveOriginalPhotos) {
        originalPaths = await StorageService.persistOriginalPhotos(
          capturesList.map((c) => c.filePath).toList(),
          primaryTimestamp,
        );
      }

      final docItem = DocumentationItem(
        id: 'doc_${primaryTimestamp.millisecondsSinceEpoch}',
        title: title,
        studentName: finalStudentName,
        description: finalDescription,
        timestamp: primaryTimestamp,
        photoTimestamps: capturesList.map((c) => c.timestamp).toList(),
        locationName: finalLocation,
        districtProvince: districtProvince,
        fullAddress: fullAddress,
        latitude: latitude,
        longitude: longitude,
        collageImagePath: collagePath,
        originalPhotoPaths: originalPaths,
        createdAt: DateTime.now(),
      );

      // Save locally
      await StorageService.saveDocumentationItem(docItem);

      _lastGeneratedItem = docItem;
      _studentName = finalStudentName;
      _editingDescription = finalDescription;
      _state = DocWorkflowState.completed;
      notifyListeners();

      // Trigger automatic share sheet if setting is enabled
      if (settings.autoWhatsAppShare) {
        await SharingService.shareDocumentation(docItem);
      }

      return docItem;
    } catch (e) {
      _errorMessage = 'Gagal membuat kolase dokumentasi: $e';
      _state = DocWorkflowState.error;
      notifyListeners();
      return null;
    }
  }

  /// Update metadata of current item after user manual editing
  Future<void> updateCurrentItemMetadata({
    required String newStudentName,
    required String newTitle,
    required String newDescription,
  }) async {
    if (_lastGeneratedItem == null) return;

    final updated = DocumentationItem(
      id: _lastGeneratedItem!.id,
      title: newTitle,
      studentName: newStudentName,
      description: newDescription,
      timestamp: _lastGeneratedItem!.timestamp,
      photoTimestamps: _lastGeneratedItem!.photoTimestamps,
      locationName: _lastGeneratedItem!.locationName,
      latitude: _lastGeneratedItem!.latitude,
      longitude: _lastGeneratedItem!.longitude,
      collageImagePath: _lastGeneratedItem!.collageImagePath,
      originalPhotoPaths: _lastGeneratedItem!.originalPhotoPaths,
      createdAt: _lastGeneratedItem!.createdAt,
    );

    _lastGeneratedItem = updated;
    _studentName = newStudentName;
    _editingTitle = newTitle;
    _editingDescription = newDescription;
    await StorageService.updateDocumentationItem(updated);
    notifyListeners();
  }
}
