import 'package:intl/intl.dart';

class TimeUtils {
  static const List<String> _monthsIndonesian = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  static const List<String> _daysIndonesian = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  static const List<String> _hijriMonths = [
    'Muharram',
    'Safar',
    'Rabi\'ul Awwal',
    'Rabi\'ul Akhir',
    'Jumadil Awwal',
    'Jumadil Akhir',
    'Rajab',
    'Sya\'ban',
    'Ramadhan',
    'Syawwal',
    'Dzulqa\'dah',
    'Dzulhijjah'
  ];

  /// Format: "Rabu, 26 Agustus 2026"
  static String formatFullDateIndonesian(DateTime date) {
    final dayName = _daysIndonesian[date.weekday - 1];
    final day = date.day;
    final monthName = _monthsIndonesian[date.month - 1];
    final year = date.year;
    return '$dayName, $day $monthName $year';
  }

  /// Format: "26 Agustus 2026"
  static String formatDateIndonesian(DateTime date) {
    final day = date.day;
    final monthName = _monthsIndonesian[date.month - 1];
    final year = date.year;
    return '$day $monthName $year';
  }

  /// Format: "15:42" (24-hour)
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Format: "15:42:05" (24-hour with seconds)
  static String formatTimeWithSeconds(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  /// Format countdown Duration: "01:24:32 remaining"
  static String formatCountdown(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Algorithmic approximation of Hijri Date (Kuwaiti algorithm adaptation)
  static String getApproximateHijriDate(DateTime date) {
    try {
      final day = date.day;
      final month = date.month;
      final year = date.year;

      int m = month;
      int y = year;
      if (m < 3) {
        y -= 1;
        m += 12;
      }

      final a = (y / 100).floor();
      final b = 2 - a + (a / 4).floor();
      final jd = (365.25 * (y + 4716)).floor() +
          (30.6001 * (m + 1)).floor() +
          day +
          b -
          1524;

      final z = jd - 1948440 + 10632;
      final n = ((z - 1) / 10631).floor();
      final zPrime = z - 10631 * n + 354;
      final j = ((10985 - zPrime) / 5316).floor() *
              ((50 * zPrime) / 17719).floor() +
          (zPrime / 5670).floor() * ((43 * zPrime) / 15238).floor();
      final zDoublePrime = zPrime -
          ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
          (j / 16).floor() * ((15238 * j) / 43).floor() +
          29;

      final hijriMonth = ((24 * zDoublePrime) / 709).floor();
      final hijriDay = zDoublePrime - ((709 * hijriMonth) / 24).floor();
      final hijriYear = 30 * n + j - 30;

      final safeMonthIndex = (hijriMonth - 1).clamp(0, 11);
      final hijriMonthName = _hijriMonths[safeMonthIndex];

      return '$hijriDay $hijriMonthName $hijriYear H';
    } catch (_) {
      return '';
    }
  }
}
