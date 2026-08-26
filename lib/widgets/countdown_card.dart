import 'package:flutter/material.dart';
import '../models/prayer_schedule.dart';
import '../utils/time_utils.dart';

class CountdownCard extends StatelessWidget {
  final DailyPrayerSchedule? schedule;
  final String locationName;
  final bool isLocationRefreshing;
  final VoidCallback onRefreshLocation;

  const CountdownCard({
    super.key,
    required this.schedule,
    required this.locationName,
    required this.isLocationRefreshing,
    required this.onRefreshLocation,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijriDate = TimeUtils.getApproximateHijriDate(now);
    final gregorianDate = TimeUtils.formatFullDateIndonesian(now);

    final nextPrayer = schedule?.nextPrayer;
    final timeRemaining = schedule?.timeRemaining ?? Duration.zero;
    final countdownStr = TimeUtils.formatCountdown(timeRemaining);
    final nextPrayerTimeStr = nextPrayer != null
        ? TimeUtils.formatTime(nextPrayer.time)
        : '--:--';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D7C66), // Deep emerald
            Color(0xFF1E5E52), // Dark forest teal
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D7C66).withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Location Badge & Refresh
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF99F6E4),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        locationName,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onRefreshLocation,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: isLocationRefreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Date labels
          Text(
            gregorianDate,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hijriDate.isNotEmpty)
            Text(
              hijriDate,
              style: const TextStyle(
                color: Color(0xFF5EEAD4),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Colors.white24, height: 1),
          ),

          // Next prayer & Live Countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SHOLAT BERIKUTNYA',
                    style: TextStyle(
                      color: Color(0xFF99F6E4),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextPrayer?.name ?? 'Memuat...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '$nextPrayerTimeStr WIB',
                    style: const TextStyle(
                      color: Color(0xFFCCFBF1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Countdown badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Menuju Waktu',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      countdownStr,
                      style: const TextStyle(
                        color: Color(0xFF5EEAD4),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
