import 'dart:io';
import 'package:flutter/foundation.dart';

class PhotoCapture {
  final int shotIndex; // 1 (Subuh), 2 (Maghrib), or 3 (Isya)
  final String filePath;
  final DateTime timestamp;
  final String prayerName; // 'Subuh', 'Maghrib', 'Isya'

  const PhotoCapture({
    required this.shotIndex,
    required this.filePath,
    required this.timestamp,
    this.prayerName = '',
  });

  File? get file => kIsWeb ? null : File(filePath);

  bool get exists {
    if (kIsWeb || filePath.startsWith('data:') || filePath.startsWith('blob:') || filePath.startsWith('http')) {
      return filePath.isNotEmpty;
    }
    try {
      return File(filePath).existsSync();
    } catch (_) {
      return filePath.isNotEmpty;
    }
  }

  Map<String, dynamic> toJson() => {
        'shotIndex': shotIndex,
        'filePath': filePath,
        'timestamp': timestamp.toIso8601String(),
        'prayerName': prayerName,
      };

  factory PhotoCapture.fromJson(Map<String, dynamic> json) => PhotoCapture(
        shotIndex: json['shotIndex'] as int,
        filePath: json['filePath'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        prayerName: json['prayerName'] as String? ?? '',
      );
}
