import 'dart:async';
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
  Timer? _localTicker;
  late final ValueNotifier<String> _countdownNotifier;

  @override
  void initState() {
    super.initState();
    _countdownNotifier = ValueNotifier<String>(_computeCountdown());
    _localTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _countdownNotifier.value = _computeCountdown();
    });
  }

  @override
  void didUpdateWidget(covariant CountdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _countdownNotifier.value = _computeCountdown();
  }

  String _computeCountdown() {
    final nextTime = widget.schedule?.nextPrayer?.time;
    if (nextTime == null) return '00:00:00';
    final diff = nextTime.difference(DateTime.now());
    return TimeUtils.formatCountdown(diff);
  }

  @override
  void dispose() {
    _localTicker?.cancel();
    _countdownNotifier.dispose();
    super.dispose();
  }

  void _handlePointer(Offset pos, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final dx = ((pos.dx / size.width) - 0.5) * 2.0;
    final dy = ((pos.dy / size.height) - 0.5) * 2.0;
    setState(() {
      _rotY = (dx * 0.10).clamp(-0.12, 0.12);
      _rotX = (-dy * 0.10).clamp(-0.12, 0.12);
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
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          transformAlignment: Alignment.center,
          transform: (_rotX == 0 && _rotY == 0)
              ? Matrix4.identity()
              : (Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateX(_rotX)
                ..rotateY(_rotY)),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [
                Color(0xF00B4F43),
                Color(0xF008322E),
                Color(0xF5051A1C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFF2DD4BF).withValues(alpha: 0.48),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.28),
                blurRadius: 22,
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              const Color(0xFF5EEAD4).withValues(alpha: 0.25),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                  color: const Color(0xFF5EEAD4).withValues(alpha: 0.22),
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

                  // 3D Glass Countdown Box (only this text rebuilds every 1s!)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.38),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF5EEAD4).withValues(alpha: 0.45),
                        width: 1.2,
                      ),
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
                        ValueListenableBuilder<String>(
                          valueListenable: _countdownNotifier,
                          builder: (context, countdownStr, _) {
                            return Text(
                              countdownStr,
                              style: const TextStyle(
                                color: Color(0xFF5EEAD4),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                letterSpacing: 1.1,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
