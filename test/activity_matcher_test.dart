import 'package:flutter_test/flutter_test.dart';
import 'package:sholat_sigma/models/prayer_schedule.dart';
import 'package:sholat_sigma/services/activity_matcher_service.dart';
import 'package:sholat_sigma/services/prayer_service.dart';

void main() {
  group('ActivityMatcherService Tests', () {
    test('Matches Ashar prayer when photo timestamp is taken in Ashar window', () {
      final date = DateTime(2026, 8, 26, 12, 0, 0);
      final schedule = PrayerService.calculateDailySchedule(
        date: date,
        latitude: -6.9175,
        longitude: 107.6191,
        locationName: 'Bandung, Jawa Barat',
      );

      final asharTime = schedule.getPrayer(PrayerType.ashar)!.time;
      final photoTime = asharTime.add(const Duration(minutes: 10));

      final detected = ActivityMatcherService.detectActivity(
        photoTimestamp: photoTime,
        dailyPrayerSchedule: schedule,
      );

      expect(detected.title, 'Dokumentasi Sholat Ashar');
      expect(detected.isPrayerMatched, isTrue);
      expect(detected.matchedPrayer, PrayerType.ashar);
    });

    test('Matches Dzuhur prayer when photo is taken in Dzuhur window', () {
      final date = DateTime(2026, 8, 26, 12, 0, 0);
      final schedule = PrayerService.calculateDailySchedule(
        date: date,
        latitude: -6.2088,
        longitude: 106.8456,
        locationName: 'Jakarta Pusat',
      );

      final dzuhurTime = schedule.getPrayer(PrayerType.dzuhur)!.time;
      final photoTime = dzuhurTime.add(const Duration(minutes: 15));

      final detected = ActivityMatcherService.detectActivity(
        photoTimestamp: photoTime,
        dailyPrayerSchedule: schedule,
      );

      expect(detected.title, 'Dokumentasi Sholat Dzuhur');
      expect(detected.isPrayerMatched, isTrue);
      expect(detected.matchedPrayer, PrayerType.dzuhur);
    });

    test('Falls back to class activity when photo is taken outside prayer window', () {
      final date = DateTime(2026, 8, 26, 12, 0, 0);
      final schedule = PrayerService.calculateDailySchedule(
        date: date,
        latitude: -6.2088,
        longitude: 106.8456,
        locationName: 'Jakarta Pusat',
      );

      final subuhTime = schedule.getPrayer(PrayerType.subuh)!.time;
      final photoTime = subuhTime.add(const Duration(hours: 3, minutes: 30));

      final detected = ActivityMatcherService.detectActivity(
        photoTimestamp: photoTime,
        dailyPrayerSchedule: schedule,
      );

      expect(detected.title, 'Dokumentasi Kegiatan Kelas');
      expect(detected.isPrayerMatched, isFalse);
    });
  });
}
