import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/documentation_item.dart';
import '../models/app_settings.dart';
import '../models/photo_capture.dart';

class StorageService {
  static const String _settingsKey = 'sholat_sigma_settings';
  static const String _studentNameKey = 'sholat_sigma_student_name';
  static const String _historyKey = 'sholat_sigma_history_json';
  static const String _historyFileName = 'documentation_history.json';
  static const String _draftSessionKey = 'sholat_sigma_draft_session';

  /// Save default student/reporter name to SharedPreferences
  static Future<void> saveDefaultStudentName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentNameKey, name);
  }

  /// Load default student/reporter name from SharedPreferences
  static Future<String> loadDefaultStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_studentNameKey) ?? '';
  }

  /// Save AppSettings to SharedPreferences
  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, settings.toJson());
  }

  /// Load AppSettings from SharedPreferences (with safe defaults)
  static Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_settingsKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        return AppSettings.fromJson(jsonString);
      }
    } catch (_) {}
    return const AppSettings();
  }

  /// Load all documentation history items (sorted newest first)
  static Future<List<DocumentationItem>> loadHistory() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final content = prefs.getString(_historyKey);
        if (content == null || content.trim().isEmpty) return [];

        final List<dynamic> jsonList = json.decode(content);
        final items = jsonList
            .map((item) => DocumentationItem.fromMap(item as Map<String, dynamic>))
            .toList();

        items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return items;
      }

      final file = await _getHistoryFile();
      if (!await file.exists()) {
        return [];
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final List<dynamic> jsonList = json.decode(content);
      final items = jsonList
          .map((item) => DocumentationItem.fromMap(item as Map<String, dynamic>))
          .toList();

      // Sort newest first
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    } catch (e) {
      return [];
    }
  }

  /// Save a new documentation item
  static Future<void> saveDocumentationItem(DocumentationItem item) async {
    try {
      final items = await loadHistory();
      // Remove duplicate if id already exists
      items.removeWhere((i) => i.id == item.id);
      items.insert(0, item);

      await _writeHistoryList(items);
    } catch (_) {}
  }

  /// Update an existing documentation item (e.g. edited title/description)
  static Future<void> updateDocumentationItem(DocumentationItem item) async {
    try {
      final items = await loadHistory();
      final index = items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        items[index] = item;
      } else {
        items.insert(0, item);
      }

      await _writeHistoryList(items);
    } catch (_) {}
  }

  /// Delete a documentation item and its associated files
  static Future<void> deleteDocumentationItem(String id) async {
    try {
      final items = await loadHistory();
      final itemToDelete = items.firstWhere((i) => i.id == id);

      if (!kIsWeb) {
        // Delete collage file
        final collageFile = File(itemToDelete.collageImagePath);
        if (await collageFile.exists()) {
          await collageFile.delete();
        }

        // Delete original photos if any
        for (final path in itemToDelete.originalPhotoPaths) {
          final origFile = File(path);
          if (await origFile.exists()) {
            await origFile.delete();
          }
        }
      }

      items.removeWhere((i) => i.id == id);
      await _writeHistoryList(items);
    } catch (_) {}
  }

  static Future<void> _writeHistoryList(List<DocumentationItem> items) async {
    final jsonList = items.map((i) => i.toMap()).toList();
    final jsonStr = json.encode(jsonList);

    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_historyKey, jsonStr);
    } else {
      final file = await _getHistoryFile();
      await file.writeAsString(jsonStr);
    }
  }

  /// Helper to get local history file path
  static Future<File> _getHistoryFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    return File('${appDir.path}/$_historyFileName');
  }

  /// Save raw original photos if setting is enabled
  static Future<List<String>> persistOriginalPhotos(
      List<String> tempPaths, DateTime timestamp) async {
    if (kIsWeb) {
      return tempPaths;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final originalsDir = Directory('${appDir.path}/originals');
      if (!originalsDir.existsSync()) {
        originalsDir.createSync(recursive: true);
      }

      final savedPaths = <String>[];
      for (int i = 0; i < tempPaths.length; i++) {
        final tempFile = File(tempPaths[i]);
        if (await tempFile.exists()) {
          final targetPath =
              '${originalsDir.path}/photo_${timestamp.millisecondsSinceEpoch}_${i + 1}.jpg';
          final savedFile = await tempFile.copy(targetPath);
          savedPaths.add(savedFile.path);
        }
      }
      return savedPaths;
    } catch (_) {
      return tempPaths;
    }
  }

  /// Copy a captured/picked slot photo into permanent app storage so it survives
  /// app close, RAM eviction, or device reboot.
  static Future<String> persistDraftSlotPhoto(
      int slotIndex, String sourcePath) async {
    try {
      if (kIsWeb) {
        if (sourcePath.startsWith('data:image')) return sourcePath;
        final xFile = XFile(sourcePath);
        final bytes = await xFile.readAsBytes();
        return 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }

      final appDir = await getApplicationDocumentsDirectory();
      final draftDir = Directory('${appDir.path}/draft_slots');
      if (!draftDir.existsSync()) {
        draftDir.createSync(recursive: true);
      }

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return sourcePath;
      }

      // If already in draft_slots, return as-is
      if (sourcePath.contains('draft_slots')) {
        return sourcePath;
      }

      // Remove any previous draft files for this same slot index
      final prefix = 'draft_slot_${slotIndex}_';
      for (final entity in draftDir.listSync()) {
        if (entity is File && entity.path.split(Platform.pathSeparator).last.startsWith(prefix)) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }

      final targetPath =
          '${draftDir.path}/${prefix}${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await sourceFile.copy(targetPath);
      return savedFile.path;
    } catch (_) {
      return sourcePath;
    }
  }

  /// Save in-progress draft session (3 prayer photo slots + form fields)
  static Future<void> saveDraftSession({
    required List<PhotoCapture?> slots,
    required String studentName,
    required String locationName,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'slots': slots.map((s) => s?.toJson()).toList(),
        'studentName': studentName,
        'locationName': locationName,
        'description': description,
      };
      await prefs.setString(_draftSessionKey, json.encode(data));
    } catch (_) {}
  }

  /// Load in-progress draft session from persistent storage
  static Future<Map<String, dynamic>?> loadDraftSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_draftSessionKey);
      if (jsonStr == null || jsonStr.trim().isEmpty) return null;

      final map = json.decode(jsonStr) as Map<String, dynamic>;
      final rawSlots = map['slots'] as List<dynamic>? ?? [null, null, null];

      final loadedSlots = <PhotoCapture?>[null, null, null];
      for (int i = 0; i < 3 && i < rawSlots.length; i++) {
        final item = rawSlots[i];
        if (item != null && item is Map<String, dynamic>) {
          final capture = PhotoCapture.fromJson(item);
          if (capture.exists) {
            loadedSlots[i] = capture;
          }
        }
      }

      return {
        'slots': loadedSlots,
        'studentName': map['studentName'] as String? ?? '',
        'locationName': map['locationName'] as String? ?? '',
        'description': map['description'] as String? ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  /// Clear in-progress draft session and delete temporary draft slot files
  static Future<void> clearDraftSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_draftSessionKey);

      if (!kIsWeb) {
        final appDir = await getApplicationDocumentsDirectory();
        final draftDir = Directory('${appDir.path}/draft_slots');
        if (draftDir.existsSync()) {
          for (final entity in draftDir.listSync()) {
            if (entity is File) {
              try {
                await entity.delete();
              } catch (_) {}
            }
          }
        }
      }
    } catch (_) {}
  }
}
