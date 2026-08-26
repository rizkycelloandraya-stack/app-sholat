import 'package:flutter/material.dart';
import '../models/prayer_schedule.dart';
import '../models/activity_time_slot.dart';

class DetectedActivity {
  final String title;
  final String suggestedDescription;
  final PrayerType? matchedPrayer;
  final bool isPrayerMatched;

  const DetectedActivity({
    required this.title,
    required this.suggestedDescription,
    this.matchedPrayer,
    required this.isPrayerMatched,
  });
}

class ActivityMatcherService {
  /// Smart Activity Detection:
  /// Evaluates photo 1 timestamp against the day's calculated prayer times first,
  /// then falls back to static time slots, and finally defaults to "Dokumentasi Kegiatan Kelas".
  static DetectedActivity detectActivity({
    required DateTime photoTimestamp,
    DailyPrayerSchedule? dailyPrayerSchedule,
  }) {
    // 1. Try matching against calculated prayer times for today
    if (dailyPrayerSchedule != null && dailyPrayerSchedule.prayers.isNotEmpty) {
      final matched = _matchWithCalculatedPrayerTimes(
        photoTimestamp,
        dailyPrayerSchedule,
      );
      if (matched != null) {
        return matched;
      }
    }

    // 2. Fallback to fixed time slot configuration
    final timeOfDay = TimeOfDay(
      hour: photoTimestamp.hour,
      minute: photoTimestamp.minute,
    );

    for (final slot in ActivityTimeSlot.defaultSlots) {
      if (slot.matchesTime(timeOfDay)) {
        return DetectedActivity(
          title: slot.title,
          suggestedDescription: 'Dokumentasi ${slot.title.toLowerCase()} bersama.',
          matchedPrayer: slot.associatedPrayer,
          isPrayerMatched: slot.associatedPrayer != null,
        );
      }
    }

    // 3. Fallback to generic class documentation
    return const DetectedActivity(
      title: ActivityTimeSlot.fallbackActivityTitle,
      suggestedDescription: 'Dokumentasi kegiatan kelas bersama.',
      matchedPrayer: null,
      isPrayerMatched: false,
    );
  }

  static DetectedActivity? _matchWithCalculatedPrayerTimes(
    DateTime photoTime,
    DailyPrayerSchedule schedule,
  ) {
    final subuh = schedule.getPrayer(PrayerType.subuh)?.time;
    final dzuhur = schedule.getPrayer(PrayerType.dzuhur)?.time;
    final ashar = schedule.getPrayer(PrayerType.ashar)?.time;
    final maghrib = schedule.getPrayer(PrayerType.maghrib)?.time;
    final isya = schedule.getPrayer(PrayerType.isya)?.time;

    // Subuh Window: Subuh - 20 mins to Subuh + 90 mins
    if (subuh != null) {
      final start = subuh.subtract(const Duration(minutes: 20));
      final end = subuh.add(const Duration(minutes: 90));
      if (photoTime.isAfter(start) && photoTime.isBefore(end)) {
        return const DetectedActivity(
          title: 'Dokumentasi Sholat Subuh',
          suggestedDescription: 'Dokumentasi kegiatan sholat Subuh bersama.',
          matchedPrayer: PrayerType.subuh,
          isPrayerMatched: true,
        );
      }
    }

    // Dzuhur Window: Dzuhur - 20 mins to Ashar or Dzuhur + 120 mins
    if (dzuhur != null) {
      final start = dzuhur.subtract(const Duration(minutes: 20));
      final end = ashar != null
          ? ashar.subtract(const Duration(minutes: 10))
          : dzuhur.add(const Duration(minutes: 120));
      if (photoTime.isAfter(start) && photoTime.isBefore(end)) {
        return const DetectedActivity(
          title: 'Dokumentasi Sholat Dzuhur',
          suggestedDescription: 'Dokumentasi kegiatan sholat Dzuhur bersama.',
          matchedPrayer: PrayerType.dzuhur,
          isPrayerMatched: true,
        );
      }
    }

    // Ashar Window: Ashar - 20 mins to Maghrib or Ashar + 120 mins
    if (ashar != null) {
      final start = ashar.subtract(const Duration(minutes: 20));
      final end = maghrib != null
          ? maghrib.subtract(const Duration(minutes: 10))
          : ashar.add(const Duration(minutes: 120));
      if (photoTime.isAfter(start) && photoTime.isBefore(end)) {
        return const DetectedActivity(
          title: 'Dokumentasi Sholat Ashar',
          suggestedDescription: 'Dokumentasi kegiatan sholat Ashar bersama.',
          matchedPrayer: PrayerType.ashar,
          isPrayerMatched: true,
        );
      }
    }

    // Maghrib Window: Maghrib - 15 mins to Isya or Maghrib + 75 mins
    if (maghrib != null) {
      final start = maghrib.subtract(const Duration(minutes: 15));
      final end = isya != null
          ? isya.subtract(const Duration(minutes: 10))
          : maghrib.add(const Duration(minutes: 75));
      if (photoTime.isAfter(start) && photoTime.isBefore(end)) {
        return const DetectedActivity(
          title: 'Dokumentasi Sholat Maghrib',
          suggestedDescription: 'Dokumentasi kegiatan sholat Maghrib bersama.',
          matchedPrayer: PrayerType.maghrib,
          isPrayerMatched: true,
        );
      }
    }

    // Isya Window: Isya - 15 mins to Isya + 150 mins
    if (isya != null) {
      final start = isya.subtract(const Duration(minutes: 15));
      final end = isya.add(const Duration(minutes: 150));
      if (photoTime.isAfter(start) && photoTime.isBefore(end)) {
        return const DetectedActivity(
          title: 'Dokumentasi Sholat Isya',
          suggestedDescription: 'Dokumentasi kegiatan sholat Isya bersama.',
          matchedPrayer: PrayerType.isya,
          isPrayerMatched: true,
        );
      }
    }

    return null;
  }
}
