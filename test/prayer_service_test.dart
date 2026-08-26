import 'package:flutter_test/flutter_test.dart';
import 'package:sholat_sigma/models/prayer_schedule.dart';
import 'package:sholat_sigma/services/prayer_service.dart';

void main() {
  group('PrayerService Tests', () {
    test('Calculates 5 daily prayer times for Jakarta coordinates', () {
      final date = DateTime(2026, 8, 26, 12, 0, 0);
      final schedule = PrayerService.calculateDailySchedule(
        date: date,
        latitude: -6.2088,
        longitude: 106.8456,
        locationName: 'Jakarta, Indonesia',
      );

      expect(schedule.prayers.length, 5);

      final subuh = schedule.getPrayer(PrayerType.subuh);
      final dzuhur = schedule.getPrayer(PrayerType.dzuhur);
      final ashar = schedule.getPrayer(PrayerType.ashar);
      final maghrib = schedule.getPrayer(PrayerType.maghrib);
      final isya = schedule.getPrayer(PrayerType.isya);

      expect(subuh, isNotNull);
      expect(dzuhur, isNotNull);
      expect(ashar, isNotNull);
      expect(maghrib, isNotNull);
      expect(isya, isNotNull);

      // Verify logical chronological order
      expect(subuh!.time.isBefore(dzuhur!.time), isTrue);
      expect(dzuhur.time.isBefore(ashar!.time), isTrue);
      expect(ashar.time.isBefore(maghrib!.time), isTrue);
      expect(maghrib.time.isBefore(isya!.time), isTrue);
    });

    test('Calculates prayer times for Bandung coordinates with Kemenag method', () {
      final date = DateTime(2026, 8, 26, 15, 42, 0);
      final schedule = PrayerService.calculateDailySchedule(
        date: date,
        latitude: -6.9175,
        longitude: 107.6191,
        locationName: 'Bandung, Jawa Barat',
        calculationMethod: 'kemenag',
        madhhab: 'shafii',
      );

      expect(schedule.locationName, 'Bandung, Jawa Barat');
      expect(schedule.prayers.length, 5);
      expect(schedule.nextPrayer, isNotNull);
    });
  });
}
