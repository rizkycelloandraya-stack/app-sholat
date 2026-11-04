import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/prayer_schedule.dart';
import '../utils/time_utils.dart';

class CountdownCard extends StatefulWidget {
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
  State<CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  double _rotX = 0.0;
  double _rotY = 0.0;

  void _handlePointer(Offset pos, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final dx = ((pos.dx / size.width) - 0.5) * 2.0;
    final dy = ((pos.dy / size.height) - 0.5) * 2.0;
    setState(() {
      _rotY = (dx * 0.12).clamp(-0.14, 0.14);
      _rotX = (-dy * 0.12).clamp(-0.14, 0.14);
    });
  }

  void _resetTilt() {
    if (_rotX == 0 && _rotY == 0) return;
    setState(() {
      _rotX = 0.0;
      _rotY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hijriDate = TimeUtils.getApproximateHijriDate(now);
    final gregorianDate = TimeUtils.formatFullDateIndonesian(now);

    final nextPrayer = widget.schedule?.nextPrayer;
    final timeRemaining = widget.schedule?.timeRemaining ?? Duration.zero;
    final countdownStr = TimeUtils.formatCountdown(timeRemaining);
    final nextPrayerTimeStr =
        nextPrayer != null ? TimeUtils.formatTime(nextPrayer.time) : '--:--';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Listener(
        onPointerDown: (e) =>
            _handlePointer(e.localPosition, context.size ?? Size.zero),
        onPointerMove: (e) =>
            _handlePointer(e.localPosition, context.size ?? Size.zero),
        onPointerUp: (_) => _resetTilt(),
        onPointerCancel: (_) => _resetTilt(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0016)
            ..rotateX(_rotX)
            ..rotateY(_rotY),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
                blurRadius: 28,
                spreadRadius: 1,
                offset: Offset(-_rotY * 60, 12 + _rotX * 60),
              ),
              BoxShadow(
                color: const Color(0xFF2DD4BF).withValues(alpha: 0.18),
                blurRadius: 42,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xDD0B4F43),
                      Color(0xDD08322E),
                      Color(0xEE051A1C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.48),
                    width: 1.4,
                  ),
                ),
                child: Stack(
                  children: [
                    // 3D Floating Glowing Orb Top-Right
                    Positioned(
                      right: -24 + (_rotY * 90),
                      top: -24 - (_rotX * 90),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF2DD4BF).withValues(alpha: 0.32),
                              const Color(0xFF10B981).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 3D Floating Glowing Orb Bottom-Left
                    Positioned(
                      left: -20 - (_rotY * 70),
                      bottom: -28 + (_rotX * 70),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFBBF24).withValues(alpha: 0.22),
                              const Color(0xFFFBBF24).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Location Badge & Refresh
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.28),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF5EEAD4)
                                        .withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: Color(0xFF5EEAD4),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        widget.locationName,
                                        style: const TextStyle(
                                          color: Color(0xFFE2E8F0),
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: widget.onRefreshLocation,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(7.0),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: widget.isLocationRefreshing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF5EEAD4)),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.refresh_rounded,
                                        color: Color(0xFF5EEAD4),
                                        size: 18,
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Date labels
                        Text(
                          gregorianDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (hijriDate.isNotEmpty)
                          Text(
                            hijriDate,
                            style: const TextStyle(
                              color: Color(0xFF5EEAD4),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF5EEAD4).withValues(alpha: 0.4),
                                  const Color(0xFF5EEAD4).withValues(alpha: 0.05),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Next prayer & Live 3D Countdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF34D399),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF34D399),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'SHOLAT BERIKUTNYA',
                                        style: TextStyle(
                                          color: Color(0xFF99F6E4),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    nextPrayer?.name ?? 'Memuat...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      shadows: [
                                        Shadow(
                                          color: Color(0x8810B981),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$nextPrayerTimeStr WIB',
                                    style: const TextStyle(
                                      color: Color(0xFFCCFBF1),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 3D Glass Countdown Cube
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 11),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.45),
                                    const Color(0xFF0D7C66)
                                        .withValues(alpha: 0.25),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFF5EEAD4)
                                      .withValues(alpha: 0.45),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2DD4BF)
                                        .withValues(alpha: 0.2),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'HITUNG MUNDUR 3D',
                                    style: TextStyle(
                                      color: Color(0xFF99F6E4),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.9,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    countdownStr,
                                    style: const TextStyle(
                                      color: Color(0xFF5EEAD4),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      fontFamily: 'monospace',
                                      letterSpacing: 1.1,
                                      shadows: [
                                        Shadow(
                                          color: Color(0x992DD4BF),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
