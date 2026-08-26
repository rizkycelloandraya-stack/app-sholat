import 'package:flutter_test/flutter_test.dart';
import 'package:sholat_sigma/models/prayer_schedule.dart';
import 'package:sholat_sigma/services/activity_matcher_service.dart';
import 'package:sholat_sigma/services/prayer_service.dart';

void main() {
  group('ActivityMatcherService Tests', () {
    test('Matches Ashar prayer when photo timestamp is taken in Ashar window', () {
      final date = DateTime(2026, 8, 26, 15, 42, 5); // 15:42:05
      final schedule = PrayerService.calculateDailySchedule(
        date: date,
        latitude: -6.9175,
        longitude: 107.6191,
        locationName: 'Bandung, Jawa Barat',
      );

      final detected = ActivityMatcherService.detectActivity(
        photoTimestamp: date,
        dailyPrayerSchedule: schedule,
      );

      expect(detected.title, 'Dokumentasi Sholat Ashar');
      expect(detected.isPrayerMatched, isTrue);
      expect(detected.matchedPrayer, PrayerType.ashar);
    });

    test('Matches Dzuhur prayer when photo is taken at 12:15', () {
      final date = DateTime(2026, 8, 26, 12, 15, 0);
      final schedule = PrayerService.calculateDailySchedule(
        date: date,
        latitude: -6.2088,
        longitude: 106.8456,
        locationName: 'Jakarta Pusat',
      );

      final detected = ActivityMatcherService.detectActivity(
        photoTimestamp: date,
        dailyPrayerSchedule: schedule,
      );

      expect(detected.title, 'Dokumentasi Sholat Dzuhur');
      expect(detected.isPrayerMatched, isTrue);
      expect(detected.matchedPrayer, PrayerType.dzuhur);
    });

    test('Falls back to class activity when photo is taken at 10:00 AM (outside prayer)', () {
      final date = DateTime(2026, 8, 26, 10, 0, 0);
      final schedule = PrayerService.calculateDailySchedule(
        date: date,
        latitude: -6.2088,
        longitude: 106.8456,
        locationName: 'Jakarta Pusat',
      );

      final detected = ActivityMatcherService.detectActivity(
        photoTimestamp: date,
        dailyPrayerSchedule: schedule,
      );

      expect(detected.title, 'Dokumentasi Kegiatan Kelas');
      expect(detected.isPrayerMatched, isFalse);
    });
  });
}
