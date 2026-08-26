import 'package:flutter/material.dart';
import '../models/prayer_schedule.dart';
import '../utils/time_utils.dart';

class PrayerCard extends StatelessWidget {
  final PrayerTimeItem prayer;

  const PrayerCard({
    super.key,
    required this.prayer,
  });

  IconData _getPrayerIcon(PrayerType type) {
    switch (type) {
      case PrayerType.subuh:
        return Icons.wb_twilight_rounded;
      case PrayerType.dzuhur:
        return Icons.wb_sunny_rounded;
      case PrayerType.ashar:
        return Icons.wb_sunny_outlined;
      case PrayerType.maghrib:
        return Icons.nights_stay_outlined;
      case PrayerType.isya:
        return Icons.nightlight_round;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNext = prayer.isNext;
    final isPassed = prayer.isPassed;

    Color cardBg;
    Color textColor;
    Color timeColor;
    Color iconBgColor;
    Color iconColor;

    if (isNext) {
      cardBg = isDark ? const Color(0xFF133E35) : const Color(0xFFE6F4F1);
      textColor = isDark ? Colors.white : const Color(0xFF0D7C66);
      timeColor = isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0D7C66);
      iconBgColor = const Color(0xFF0D7C66);
      iconColor = Colors.white;
    } else if (isPassed) {
      cardBg = isDark ? const Color(0xFF18201E) : const Color(0xFFF1F5F9);
      textColor = isDark ? Colors.white38 : const Color(0xFF94A3B8);
      timeColor = isDark ? Colors.white38 : const Color(0xFF94A3B8);
      iconBgColor = isDark ? const Color(0xFF222B28) : const Color(0xFFE2E8F0);
      iconColor = isDark ? Colors.white38 : const Color(0xFF94A3B8);
    } else {
      cardBg = isDark ? const Color(0xFF1E2825) : Colors.white;
      textColor = isDark ? Colors.white : const Color(0xFF1E293B);
      timeColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155);
      iconBgColor = isDark ? const Color(0xFF2D3C37) : const Color(0xFFF1F5F9);
      iconColor = isDark ? const Color(0xFF41B3A2) : const Color(0xFF0D7C66);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNext
              ? const Color(0xFF0D7C66).withValues(alpha: 0.5)
              : (isDark ? const Color(0xFF273430) : const Color(0xFFE2E8F0)),
          width: isNext ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Prayer Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getPrayerIcon(prayer.type),
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Prayer Name
          Expanded(
            child: Row(
              children: [
                Text(
                  prayer.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (isNext) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D7C66),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Selanjutnya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Prayer Time
          Text(
            '${TimeUtils.formatTime(prayer.time)} WIB',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isNext ? FontWeight.w800 : FontWeight.w700,
              color: timeColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
