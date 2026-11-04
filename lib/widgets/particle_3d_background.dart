import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class _Particle3D {
  double x; // -1.0 to 1.0
  double y; // -1.0 to 1.0
  double z; // 0.1 to 2.0 (depth)
  double vx;
  double vy;
  double vz;
  double baseRadius;
  int colorIndex;
  double phase;

  _Particle3D({
    required this.x,
    required this.y,
    required this.z,
    required this.vx,
    required this.vy,
    required this.vz,
    required this.baseRadius,
    required this.colorIndex,
    required this.phase,
  });
}

/// Full-screen interactive 3D perspective particle background with constellation
/// depth lines, floating 3D bokeh orbs, and touch-reactive camera parallax.
class Particle3DBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;

  const Particle3DBackground({
    super.key,
    required this.child,
    this.particleCount = 75,
  });

  @override
  State<Particle3DBackground> createState() => _Particle3DBackgroundState();
}

class _Particle3DBackgroundState extends State<Particle3DBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle3D> _particles = [];
  final math.Random _rng = math.Random(42);

  Offset _pointerOffset = Offset.zero;
  Offset _targetPointerOffset = Offset.zero;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addListener(_updatePhysics);
    _controller.repeat();
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(
        _Particle3D(
          x: (_rng.nextDouble() * 2.4) - 1.2,
          y: (_rng.nextDouble() * 2.4) - 1.2,
          z: 0.15 + _rng.nextDouble() * 1.85,
          vx: (_rng.nextDouble() - 0.5) * 0.0022,
          vy: (_rng.nextDouble() - 0.5) * 0.0022 - 0.0006,
          vz: (_rng.nextDouble() - 0.5) * 0.0035,
          baseRadius: 1.6 + _rng.nextDouble() * 3.8,
          colorIndex: i % 4,
          phase: _rng.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  void _updatePhysics() {
    _time += 0.016;
    // Smooth interpolation for touch/pointer 3D camera parallax
    _pointerOffset = Offset.lerp(_pointerOffset, _targetPointerOffset, 0.08) ??
        Offset.zero;

    for (final p in _particles) {
      // Subtle 3D orbital swirl + upward float
      final swirlX = math.sin(_time * 0.4 + p.phase) * 0.0007;
      final swirlY = math.cos(_time * 0.35 + p.phase) * 0.0007;

      p.x += p.vx + swirlX;
      p.y += p.vy + swirlY;
      p.z += p.vz;

      // Wrap around 3D frustum bounds
      if (p.z < 0.12) {
        p.z = 1.95;
        p.x = (_rng.nextDouble() * 2.2) - 1.1;
        p.y = (_rng.nextDouble() * 2.2) - 1.1;
      } else if (p.z > 2.0) {
        p.z = 0.15;
      }

      if (p.x < -1.3) p.x = 1.3;
      if (p.x > 1.3) p.x = -1.3;
      if (p.y < -1.3) p.y = 1.3;
      if (p.y > 1.3) p.y = -1.3;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePointerMove(PointerEvent event, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final nx = ((event.localPosition.dx / size.width) - 0.5) * 2.0;
    final ny = ((event.localPosition.dy / size.height) - 0.5) * 2.0;
    _targetPointerOffset = Offset(nx.clamp(-1.0, 1.0), ny.clamp(-1.0, 1.0));
  }

  void _handlePointerReset(PointerEvent event) {
    _targetPointerOffset = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) => _handlePointerMove(e, size),
          onPointerMove: (e) => _handlePointerMove(e, size),
          onPointerUp: _handlePointerReset,
          onPointerCancel: _handlePointerReset,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Deep 3D Cosmic / Emerald Space Backdrop
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      -0.3 + _pointerOffset.dx * 0.25,
                      -0.4 + _pointerOffset.dy * 0.25,
                    ),
                    radius: 1.35,
                    colors: isDark
                        ? const [
                            Color(0xFF0D2E28),
                            Color(0xFF071717),
                            Color(0xFF03090C),
                          ]
                        : const [
                            Color(0xFFD1FAE5),
                            Color(0xFFECFDF5),
                            Color(0xFFF0F9FF),
                          ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),

              // 3D Particle Projection Canvas
              RepaintBoundary(
                child: CustomPaint(
                  painter: _Particle3DPainter(
                    particles: _particles,
                    pointerOffset: _pointerOffset,
                    time: _time,
                    isDark: isDark,
                  ),
                  size: Size.infinite,
                ),
              ),

              // Foreground Content
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _Particle3DPainter extends CustomPainter {
  final List<_Particle3D> particles;
  final Offset pointerOffset;
  final double time;
  final bool isDark;

  _Particle3DPainter({
    required this.particles,
    required this.pointerOffset,
    required this.time,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final scale = math.max(size.width, size.height) * 0.62;
    const focalLength = 1.15;

    final palette = isDark
        ? const [
            Color(0xFF34D399), // Neon Emerald
            Color(0xFF2DD4BF), // Cyber Teal
            Color(0xFFFBBF24), // Warm Gold Star
            Color(0xFF38BDF8), // Celestial Cyan
          ]
        : const [
            Color(0xFF0D7C66),
            Color(0xFF059669),
            Color(0xFFD97706),
            Color(0xFF0284C7),
          ];

    // 1. Draw subtle 3D perspective horizon grid rings at the top/center
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D7C66))
          .withValues(alpha: isDark ? 0.08 : 0.06);

    canvas.save();
    canvas.translate(
      cx + pointerOffset.dx * 18,
      size.height * 0.22 + pointerOffset.dy * 14,
    );
    for (int r = 1; r <= 3; r++) {
      final radius = r * 85.0 + math.sin(time * 0.8 + r) * 6.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 2.1,
          height: radius * 0.72,
        ),
        ringPaint,
      );
    }
    canvas.restore();

    // 2. Project 3D coordinates (x, y, z) -> 2D screen coordinates with camera tilt
    final projected = <({
      double sx,
      double sy,
      double z,
      double radius,
      double alpha,
      Color color,
    })>[];

    final camRotY = pointerOffset.dx * 0.28 + math.sin(time * 0.25) * 0.08;
    final camRotX = -pointerOffset.dy * 0.22 + math.cos(time * 0.2) * 0.06;
    final cosY = math.cos(camRotY);
    final sinY = math.sin(camRotY);
    final cosX = math.cos(camRotX);
    final sinX = math.sin(camRotX);

    for (final p in particles) {
      // Rotate around Y axis
      final rx = p.x * cosY - (p.z - 1.0) * sinY;
      final rz1 = p.x * sinY + (p.z - 1.0) * cosY;

      // Rotate around X axis
      final ry = p.y * cosX - rz1 * sinX;
      final rz = (p.y * sinX + rz1 * cosX) + 1.15;

      if (rz <= 0.08) continue;

      final perspective = focalLength / rz;
      final sx = cx + rx * scale * perspective;
      final sy = cy + ry * scale * perspective;

      if (sx < -60 ||
          sx > size.width + 60 ||
          sy < -60 ||
          sy > size.height + 60) {
        continue;
      }

      final depthFactor = (1.0 - (rz / 2.3)).clamp(0.08, 1.0);
      final pulse = 0.75 + 0.25 * math.sin(time * 2.2 + p.phase);
      final alpha = (depthFactor * pulse * (isDark ? 0.88 : 0.55)).clamp(0.05, 0.95);
      final radius = (p.baseRadius * perspective).clamp(0.8, 9.5);

      projected.add((
        sx: sx,
        sy: sy,
        z: rz,
        radius: radius,
        alpha: alpha,
        color: palette[p.colorIndex],
      ));
    }

    // Sort back-to-front (painter's algorithm for 3D depth)
    projected.sort((a, b) => b.z.compareTo(a.z));

    // 3. Draw 3D constellation neural lines between nearby foreground particles
    final linePaint = Paint()
      ..strokeWidth = 0.85
      ..style = PaintingStyle.stroke;

    final maxConnectDistSq = 115.0 * 115.0;
    for (int i = 0; i < projected.length; i++) {
      final a = projected[i];
      if (a.z > 1.45) continue; // Only connect closer 3D layers
      int connections = 0;
      for (int j = i + 1; j < projected.length; j++) {
        final b = projected[j];
        if ((a.z - b.z).abs() > 0.38) continue;
        final dx = a.sx - b.sx;
        final dy = a.sy - b.sy;
        final distSq = dx * dx + dy * dy;
        if (distSq < maxConnectDistSq) {
          final proximity = 1.0 - (distSq / maxConnectDistSq);
          final lineAlpha = (proximity * a.alpha * (isDark ? 0.28 : 0.18))
              .clamp(0.01, 0.35);
          linePaint.color = a.color.withValues(alpha: lineAlpha);
          canvas.drawLine(Offset(a.sx, a.sy), Offset(b.sx, b.sy), linePaint);
          connections++;
          if (connections >= 3) break;
        }
      }
    }

    // 4. Draw 3D particles with outer glow + bright 3D core
    final glowPaint = Paint()..style = PaintingStyle.fill;
    final corePaint = Paint()..style = PaintingStyle.fill;

    for (final pt in projected) {
      final center = Offset(pt.sx, pt.sy);

      // Soft 3D bloom halo
      if (pt.radius > 1.8) {
        glowPaint.color = pt.color.withValues(alpha: pt.alpha * 0.24);
        canvas.drawCircle(center, pt.radius * 2.6, glowPaint);
      }

      // Main 3D sphere body
      corePaint.color = pt.color.withValues(alpha: pt.alpha);
      canvas.drawCircle(center, pt.radius, corePaint);

      // Specular 3D highlight on close particles
      if (pt.radius > 2.4 && isDark) {
        corePaint.color = Colors.white.withValues(alpha: pt.alpha * 0.75);
        canvas.drawCircle(
          Offset(pt.sx - pt.radius * 0.25, pt.sy - pt.radius * 0.25),
          pt.radius * 0.32,
          corePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Particle3DPainter oldDelegate) => true;
}

/// Interactive 3D Tilt & Glassmorphic Card wrapper that responds to touch
/// with 3D perspective rotation and glowing specular borders.
class Glass3DCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? glowColor;
  final bool enableTilt;
  final VoidCallback? onTap;

  const Glass3DCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.borderRadius = 22,
    this.glowColor,
    this.enableTilt = true,
    this.onTap,
  });

  @override
  State<Glass3DCard> createState() => _Glass3DCardState();
}

class _Glass3DCardState extends State<Glass3DCard> {
  double _rotX = 0.0;
  double _rotY = 0.0;
  bool _isPressed = false;

  void _onPanUpdate(Offset localPos, Size size) {
    if (!widget.enableTilt || size.width <= 0 || size.height <= 0) return;
    final dx = ((localPos.dx / size.width) - 0.5) * 2.0;
    final dy = ((localPos.dy / size.height) - 0.5) * 2.0;
    setState(() {
      _rotY = (dx * 0.08).clamp(-0.1, 0.1);
      _rotX = (-dy * 0.08).clamp(-0.1, 0.1);
      _isPressed = true;
    });
  }

  void _onReset() {
    if (!_isPressed && _rotX == 0 && _rotY == 0) return;
    setState(() {
      _rotX = 0.0;
      _rotY = 0.0;
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.glowColor ?? const Color(0xFF2DD4BF);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: widget.margin ?? EdgeInsets.zero,
          child: Listener(
            onPointerDown: (e) =>
                _onPanUpdate(e.localPosition, context.size ?? Size.zero),
            onPointerMove: (e) =>
                _onPanUpdate(e.localPosition, context.size ?? Size.zero),
            onPointerUp: (_) => _onReset(),
            onPointerCancel: (_) => _onReset(),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                transformAlignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0014)
                  ..rotateX(_rotX)
                  ..rotateY(_rotY),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(
                        alpha: _isPressed
                            ? (isDark ? 0.28 : 0.18)
                            : (isDark ? 0.12 : 0.07),
                      ),
                      blurRadius: _isPressed ? 24 : 16,
                      spreadRadius: _isPressed ? 1 : 0,
                      offset: Offset(-_rotY * 40, 8 + _rotX * 40),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: widget.padding,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.borderRadius),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  const Color(0xFF162E2A).withValues(alpha: 0.78),
                                  const Color(0xFF0C1A1A).withValues(alpha: 0.68),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.88),
                                  const Color(0xFFF0FDF9).withValues(alpha: 0.78),
                                ],
                        ),
                        border: Border.all(
                          color: isDark
                              ? accent.withValues(alpha: _isPressed ? 0.55 : 0.28)
                              : accent.withValues(alpha: _isPressed ? 0.45 : 0.22),
                          width: _isPressed ? 1.5 : 1.1,
                        ),
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
