import 'package:flutter/material.dart';
import 'prayer_schedule.dart';

class ActivityTimeSlot {
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final PrayerType? associatedPrayer;

  const ActivityTimeSlot({
    required this.title,
    required this.startTime,
    required this.endTime,
    this.associatedPrayer,
  });

  bool matchesTime(TimeOfDay time) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final currentMinutes = time.hour * 60 + time.minute;

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Wraps around midnight (e.g. 23:00 to 01:00)
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  static const List<ActivityTimeSlot> defaultSlots = [
    ActivityTimeSlot(
      title: 'Dokumentasi Sholat Subuh',
      startTime: TimeOfDay(hour: 4, minute: 0),
      endTime: TimeOfDay(hour: 5, minute: 30),
      associatedPrayer: PrayerType.subuh,
    ),
    ActivityTimeSlot(
      title: 'Dokumentasi Sholat Dzuhur',
      startTime: TimeOfDay(hour: 11, minute: 30),
      endTime: TimeOfDay(hour: 13, minute: 30),
      associatedPrayer: PrayerType.dzuhur,
    ),
    ActivityTimeSlot(
      title: 'Dokumentasi Sholat Ashar',
      startTime: TimeOfDay(hour: 14, minute: 30),
      endTime: TimeOfDay(hour: 16, minute: 30),
      associatedPrayer: PrayerType.ashar,
    ),
    ActivityTimeSlot(
      title: 'Dokumentasi Sholat Maghrib',
      startTime: TimeOfDay(hour: 17, minute: 30),
      endTime: TimeOfDay(hour: 19, minute: 0),
      associatedPrayer: PrayerType.maghrib,
    ),
    ActivityTimeSlot(
      title: 'Dokumentasi Sholat Isya',
      startTime: TimeOfDay(hour: 19, minute: 0),
      endTime: TimeOfDay(hour: 21, minute: 0),
      associatedPrayer: PrayerType.isya,
    ),
  ];

  static const String fallbackActivityTitle = 'Dokumentasi Kegiatan Kelas';
}
