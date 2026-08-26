enum PrayerType {
  subuh,
  dzuhur,
  ashar,
  maghrib,
  isya,
}

extension PrayerTypeExtension on PrayerType {
  String get displayName {
    switch (this) {
      case PrayerType.subuh:
        return 'Subuh';
      case PrayerType.dzuhur:
        return 'Dzuhur';
      case PrayerType.ashar:
        return 'Ashar';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isya:
        return 'Isya';
    }
  }

  String get documentationTitle {
    switch (this) {
      case PrayerType.subuh:
        return 'Dokumentasi Sholat Subuh';
      case PrayerType.dzuhur:
        return 'Dokumentasi Sholat Dzuhur';
      case PrayerType.ashar:
        return 'Dokumentasi Sholat Ashar';
      case PrayerType.maghrib:
        return 'Dokumentasi Sholat Maghrib';
      case PrayerType.isya:
        return 'Dokumentasi Sholat Isya';
    }
  }
}

class PrayerTimeItem {
  final PrayerType type;
  final String name;
  final DateTime time;
  final bool isPassed;
  final bool isCurrent;
  final bool isNext;

  const PrayerTimeItem({
    required this.type,
    required this.name,
    required this.time,
    this.isPassed = false,
    this.isCurrent = false,
    this.isNext = false,
  });

  PrayerTimeItem copyWith({
    bool? isPassed,
    bool? isCurrent,
    bool? isNext,
  }) {
    return PrayerTimeItem(
      type: type,
      name: name,
      time: time,
      isPassed: isPassed ?? this.isPassed,
      isCurrent: isCurrent ?? this.isCurrent,
      isNext: isNext ?? this.isNext,
    );
  }
}

class DailyPrayerSchedule {
  final DateTime date;
  final List<PrayerTimeItem> prayers;
  final PrayerTimeItem? nextPrayer;
  final Duration? timeRemaining;
  final String locationName;
  final double latitude;
  final double longitude;

  const DailyPrayerSchedule({
    required this.date,
    required this.prayers,
    this.nextPrayer,
    this.timeRemaining,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  PrayerTimeItem? getPrayer(PrayerType type) {
    try {
      return prayers.firstWhere((p) => p.type == type);
    } catch (_) {
      return null;
    }
  }
}
