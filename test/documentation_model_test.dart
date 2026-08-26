import 'package:flutter_test/flutter_test.dart';
import 'package:sholat_sigma/models/app_settings.dart';
import 'package:sholat_sigma/models/documentation_item.dart';
import 'package:sholat_sigma/models/photo_capture.dart';

void main() {
  group('Models Serialization Tests', () {
    test('PhotoCapture serialization', () {
      final now = DateTime(2026, 8, 26, 15, 42, 5);
      final photo = PhotoCapture(
        shotIndex: 1,
        filePath: '/storage/photo_1.jpg',
        timestamp: now,
      );

      final json = photo.toJson();
      final restored = PhotoCapture.fromJson(json);

      expect(restored.shotIndex, 1);
      expect(restored.filePath, '/storage/photo_1.jpg');
      expect(restored.timestamp, now);
    });

    test('DocumentationItem serialization', () {
      final now = DateTime(2026, 8, 26, 15, 42, 5);
      final item = DocumentationItem(
        id: 'doc_12345',
        title: 'Dokumentasi Sholat Ashar',
        description: 'Dokumentasi kegiatan sholat Ashar bersama.',
        timestamp: now,
        photoTimestamps: [
          now,
          now.add(const Duration(seconds: 15)),
          now.add(const Duration(seconds: 32)),
        ],
        locationName: 'Bandung, Jawa Barat',
        latitude: -6.9175,
        longitude: 107.6191,
        collageImagePath: '/storage/collages/sigma_doc.jpg',
        originalPhotoPaths: ['/storage/p1.jpg', '/storage/p2.jpg'],
        createdAt: now,
      );

      final json = item.toJson();
      final restored = DocumentationItem.fromJson(json);

      expect(restored.id, 'doc_12345');
      expect(restored.title, 'Dokumentasi Sholat Ashar');
      expect(restored.photoTimestamps.length, 3);
      expect(restored.locationName, 'Bandung, Jawa Barat');
      expect(restored.latitude, -6.9175);
    });

    test('AppSettings serialization with defaults', () {
      const settings = AppSettings();
      expect(settings.alarmSubuh, isTrue);
      expect(settings.auto3PhotoMode, isTrue);
      expect(settings.autoWhatsAppShare, isTrue);
      expect(settings.saveOriginalPhotos, isFalse);

      final json = settings.toJson();
      final restored = AppSettings.fromJson(json);

      expect(restored.calculationMethod, 'kemenag');
      expect(restored.reminderMinutesBefore, 0);
    });
  });
}
