import 'package:adhan/adhan.dart';
import '../models/prayer_schedule.dart';

class PrayerService {
  // Default coordinates (Jakarta, Indonesia) if GPS is not yet acquired
  static const double defaultLatitude = -6.2088;
  static const double defaultLongitude = 106.8456;
  static const String defaultLocationName = 'Indonesia (Default)';

  /// Calculation parameters mapping
  static CalculationParameters _getCalculationParameters(
      String method, String madhhab) {
    CalculationParameters params;

    switch (method.toLowerCase()) {
      case 'kemenag':
      case 'indonesia':
        // Indonesian Ministry of Religious Affairs (Kemenag) Standard:
        // Fajr angle: 20 degrees, Isha angle: 18 degrees
        params = CalculationMethod.singapore.getParameters();
        params.fajrAngle = 20.0;
        params.ishaAngle = 18.0;
        // Standard 2-minute safety buffer (ihtiyat) for Indonesia
        params.adjustments.fajr = 2;
        params.adjustments.dhuhr = 2;
        params.adjustments.asr = 2;
        params.adjustments.maghrib = 2;
        params.adjustments.isha = 2;
        break;
      case 'muslim_world_league':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'egyptian':
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 'karachi':
        params = CalculationMethod.karachi.getParameters();
        break;
      case 'umm_al_qura':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'north_america':
      case 'isna':
        params = CalculationMethod.north_america.getParameters();
        break;
      default:
        params = CalculationMethod.singapore.getParameters();
        params.fajrAngle = 20.0;
        params.ishaAngle = 18.0;
        params.adjustments.fajr = 2;
        params.adjustments.dhuhr = 2;
        params.adjustments.asr = 2;
        params.adjustments.maghrib = 2;
        params.adjustments.isha = 2;
        break;
    }

    if (madhhab.toLowerCase() == 'hanafi') {
      params.madhab = Madhab.hanafi;
    } else {
      params.madhab = Madhab.shafi;
    }

    return params;
  }

  /// Calculates prayer schedule for a specific date and coordinates
  static DailyPrayerSchedule calculateDailySchedule({
    required DateTime date,
    required double latitude,
    required double longitude,
    required String locationName,
    String calculationMethod = 'kemenag',
    String madhhab = 'shafii',
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final dateComponents = DateComponents.from(date);
    final params = _getCalculationParameters(calculationMethod, madhhab);

    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    final now = DateTime.now();

    final List<PrayerTimeItem> items = [
      PrayerTimeItem(
        type: PrayerType.subuh,
        name: PrayerType.subuh.displayName,
        time: prayerTimes.fajr.toLocal(),
      ),
      PrayerTimeItem(
        type: PrayerType.dzuhur,
        name: PrayerType.dzuhur.displayName,
        time: prayerTimes.dhuhr.toLocal(),
      ),
      PrayerTimeItem(
        type: PrayerType.ashar,
        name: PrayerType.ashar.displayName,
        time: prayerTimes.asr.toLocal(),
      ),
      PrayerTimeItem(
        type: PrayerType.maghrib,
        name: PrayerType.maghrib.displayName,
        time: prayerTimes.maghrib.toLocal(),
      ),
      PrayerTimeItem(
        type: PrayerType.isya,
        name: PrayerType.isya.displayName,
        time: prayerTimes.isha.toLocal(),
      ),
    ];

    // Find next and current prayer
    PrayerTimeItem? nextItem;
    Duration? timeRemaining;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.time.isAfter(now)) {
        nextItem = item;
        timeRemaining = item.time.difference(now);
        break;
      }
    }

    // If all prayers for today have passed, the next prayer is Subuh tomorrow
    if (nextItem == null) {
      final tomorrow = date.add(const Duration(days: 1));
      final tomorrowComponents = DateComponents.from(tomorrow);
      final tomorrowTimes =
          PrayerTimes(coordinates, tomorrowComponents, params);
      final tomorrowSubuhTime = tomorrowTimes.fajr.toLocal();

      nextItem = PrayerTimeItem(
        type: PrayerType.subuh,
        name: '${PrayerType.subuh.displayName} (Besok)',
        time: tomorrowSubuhTime,
        isNext: true,
      );
      timeRemaining = tomorrowSubuhTime.difference(now);
    }

    // Build updated items with status
    final updatedItems = items.map((item) {
      final isPassed = now.isAfter(item.time);
      final isNext = nextItem != null &&
          item.type == nextItem.type &&
          item.time.day == nextItem.time.day;

      return item.copyWith(
        isPassed: isPassed && !isNext,
        isNext: isNext,
      );
    }).toList();

    return DailyPrayerSchedule(
      date: date,
      prayers: updatedItems,
      nextPrayer: nextItem,
      timeRemaining: timeRemaining,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
