import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/documentation_item.dart';
import '../models/app_settings.dart';

class StorageService {
  static const String _settingsKey = 'sholat_sigma_settings';
  static const String _studentNameKey = 'sholat_sigma_student_name';
  static const String _historyKey = 'sholat_sigma_history_json';
  static const String _historyFileName = 'documentation_history.json';

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
}
