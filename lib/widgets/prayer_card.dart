import 'package:flutter/material.dart';
import '../models/prayer_schedule.dart';
import '../utils/time_utils.dart';
import 'particle_3d_background.dart';

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

  Color _getPrayerAccent(PrayerType type) {
    switch (type) {
      case PrayerType.subuh:
        return const Color(0xFF38BDF8);
      case PrayerType.dzuhur:
        return const Color(0xFFFBBF24);
      case PrayerType.ashar:
        return const Color(0xFFFB923C);
      case PrayerType.maghrib:
        return const Color(0xFFF472B6);
      case PrayerType.isya:
        return const Color(0xFFA78BFA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNext = prayer.isNext;
    final isPassed = prayer.isPassed;
    final accent = isNext ? const Color(0xFF2DD4BF) : _getPrayerAccent(prayer.type);

    Color textColor;
    Color timeColor;

    if (isNext) {
      textColor = isDark ? Colors.white : const Color(0xFF065F46);
      timeColor = isDark ? const Color(0xFF5EEAD4) : const Color(0xFF047857);
    } else if (isPassed) {
      textColor = isDark ? Colors.white38 : const Color(0xFF94A3B8);
      timeColor = isDark ? Colors.white38 : const Color(0xFF94A3B8);
    } else {
      textColor = isDark ? Colors.white : const Color(0xFF0F172A);
      timeColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
    }

    return Glass3DCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderRadius: 20,
      glowColor: isNext ? const Color(0xFF2DD4BF) : (isPassed ? Colors.transparent : accent),
      child: Row(
        children: [
          // 3D Glowing Orb Prayer Icon
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isPassed
                  ? null
                  : RadialGradient(
                      colors: [
                        accent.withValues(alpha: isNext ? 0.95 : 0.35),
                        accent.withValues(alpha: isNext ? 0.45 : 0.12),
                      ],
                    ),
              color: isPassed
                  ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0))
                  : null,
              border: Border.all(
                color: isPassed
                    ? Colors.transparent
                    : accent.withValues(alpha: isNext ? 0.9 : 0.45),
                width: 1.2,
              ),
              boxShadow: isPassed
                  ? null
                  : [
                      BoxShadow(
                        color: accent.withValues(alpha: isNext ? 0.5 : 0.25),
                        blurRadius: isNext ? 14 : 8,
                        spreadRadius: isNext ? 1 : 0,
                      ),
                    ],
            ),
            child: Icon(
              _getPrayerIcon(prayer.type),
              color: isPassed
                  ? (isDark ? Colors.white38 : const Color(0xFF94A3B8))
                  : (isNext ? Colors.white : accent),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Prayer Name & Next 3D Pill
          Expanded(
            child: Row(
              children: [
                Text(
                  prayer.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isNext ? FontWeight.w900 : FontWeight.w700,
                    color: textColor,
                    shadows: isNext && isDark
                        ? const [
                            Shadow(
                              color: Color(0x882DD4BF),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (isNext) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF10B981),
                          Color(0xFF0D9488),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text(
                      'AKTIF 3D',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
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
              fontWeight: isNext ? FontWeight.w900 : FontWeight.w700,
              color: timeColor,
              letterSpacing: 0.3,
              shadows: isNext && isDark
                  ? const [
                      Shadow(
                        color: Color(0x882DD4BF),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
