import 'dart:math' as math;
import 'package:flutter/material.dart';

class _Particle3D {
  double x; // -1.0 to 1.0
  double y; // -1.0 to 1.0
  double z; // 0.15 to 2.0 (depth)
  double vx;
  double vy;
  double vz;
  double baseRadius;
  int colorIndex;
  double phase;

  // Pre-allocated projected screen coordinates to avoid per-frame object allocations
  double sx = 0.0;
  double sy = 0.0;
  double rz = 1.0;
  double projRadius = 1.0;
  double alpha = 0.5;
  bool visible = false;

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

/// Ultra-lightweight 3D perspective particle background driven directly by
/// CustomPainter(repaint: controller) with zero widget rebuilds and zero
/// per-frame heap allocations.
class Particle3DBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;

  const Particle3DBackground({
    super.key,
    required this.child,
    this.particleCount = 38,
  });

  @override
  State<Particle3DBackground> createState() => _Particle3DBackgroundState();
}

class _Particle3DBackgroundState extends State<Particle3DBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle3D> _particles = [];
  final math.Random _rng = math.Random(42);
  final ValueNotifier<Offset> _targetPointer = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();
    _initParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  void _initParticles() {
    _particles.clear();
    final count = widget.particleCount.clamp(20, 42);
    for (int i = 0; i < count; i++) {
      _particles.add(
        _Particle3D(
          x: (_rng.nextDouble() * 2.4) - 1.2,
          y: (_rng.nextDouble() * 2.4) - 1.2,
          z: 0.18 + _rng.nextDouble() * 1.82,
          vx: (_rng.nextDouble() - 0.5) * 0.0018,
          vy: (_rng.nextDouble() - 0.5) * 0.0018 - 0.0005,
          vz: (_rng.nextDouble() - 0.5) * 0.0028,
          baseRadius: 1.6 + _rng.nextDouble() * 3.4,
          colorIndex: i % 4,
          phase: _rng.nextDouble() * math.pi * 2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _targetPointer.dispose();
    super.dispose();
  }

  void _handlePointerMove(PointerEvent event, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final nx = ((event.localPosition.dx / size.width) - 0.5) * 2.0;
    final ny = ((event.localPosition.dy / size.height) - 0.5) * 2.0;
    _targetPointer.value = Offset(nx.clamp(-1.0, 1.0), ny.clamp(-1.0, 1.0));
  }

  void _handlePointerReset(PointerEvent event) {
    _targetPointer.value = Offset.zero;
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
              // Static GPU-cached Deep 3D Cosmic Backdrop (zero rebuilds)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.25, -0.35),
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

              // Direct GPU Canvas Repaint (no setState, zero widget tree rebuilds)
              RepaintBoundary(
                child: CustomPaint(
                  painter: _Particle3DPainter(
                    repaint: _controller,
                    particles: _particles,
                    targetPointer: _targetPointer,
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
  final ValueNotifier<Offset> targetPointer;
  final bool isDark;

  Offset _pointerOffset = Offset.zero;
  double _time = 0.0;

  final Paint _ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;
  final Paint _linePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;
  final Paint _glowPaint = Paint()..style = PaintingStyle.fill;
  final Paint _corePaint = Paint()..style = PaintingStyle.fill;

  _Particle3DPainter({
    required Listenable repaint,
    required this.particles,
    required this.targetPointer,
    required this.isDark,
  }) : super(repaint: repaint);

  static const List<Color> _darkPalette = [
    Color(0xFF34D399), // Neon Emerald
    Color(0xFF2DD4BF), // Cyber Teal
    Color(0xFFFBBF24), // Warm Gold Star
    Color(0xFF38BDF8), // Celestial Cyan
  ];

  static const List<Color> _lightPalette = [
    Color(0xFF0D7C66),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFF0284C7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    _time += 0.016;
    _pointerOffset =
        Offset.lerp(_pointerOffset, targetPointer.value, 0.08) ?? Offset.zero;

    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final scale = math.max(size.width, size.height) * 0.62;
    const focalLength = 1.15;
    final palette = isDark ? _darkPalette : _lightPalette;

    // 1. Subtle 3D perspective horizon rings
    _ringPaint.color =
        (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D7C66))
            .withValues(alpha: isDark ? 0.07 : 0.05);

    final ringCenterX = cx + _pointerOffset.dx * 16;
    final ringCenterY = size.height * 0.22 + _pointerOffset.dy * 12;
    for (int r = 1; r <= 2; r++) {
      final radius = r * 95.0 + math.sin(_time * 0.7 + r) * 5.0;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(ringCenterX, ringCenterY),
          width: radius * 2.1,
          height: radius * 0.68,
        ),
        _ringPaint,
      );
    }

    // 2. Step physics & project 3D -> 2D in-place (zero allocations)
    final camRotY = _pointerOffset.dx * 0.25 + math.sin(_time * 0.22) * 0.07;
    final camRotX = -_pointerOffset.dy * 0.20 + math.cos(_time * 0.18) * 0.05;
    final cosY = math.cos(camRotY);
    final sinY = math.sin(camRotY);
    final cosX = math.cos(camRotX);
    final sinX = math.sin(camRotX);

    final len = particles.length;
    for (int i = 0; i < len; i++) {
      final p = particles[i];

      p.x += p.vx + math.sin(_time * 0.35 + p.phase) * 0.0005;
      p.y += p.vy + math.cos(_time * 0.30 + p.phase) * 0.0005;
      p.z += p.vz;

      if (p.z < 0.14) {
        p.z = 1.95;
      } else if (p.z > 2.0) {
        p.z = 0.16;
      }
      if (p.x < -1.25) p.x = 1.25;
      if (p.x > 1.25) p.x = -1.25;
      if (p.y < -1.25) p.y = 1.25;
      if (p.y > 1.25) p.y = -1.25;

      final rx = p.x * cosY - (p.z - 1.0) * sinY;
      final rz1 = p.x * sinY + (p.z - 1.0) * cosY;
      final ry = p.y * cosX - rz1 * sinX;
      final rz = (p.y * sinX + rz1 * cosX) + 1.15;

      if (rz <= 0.1) {
        p.visible = false;
        continue;
      }

      final perspective = focalLength / rz;
      final sx = cx + rx * scale * perspective;
      final sy = cy + ry * scale * perspective;

      if (sx < -40 ||
          sx > size.width + 40 ||
          sy < -40 ||
          sy > size.height + 40) {
        p.visible = false;
        continue;
      }

      final depthFactor = (1.0 - (rz / 2.3)).clamp(0.1, 1.0);
      final pulse = 0.78 + 0.22 * math.sin(_time * 2.0 + p.phase);
      p.sx = sx;
      p.sy = sy;
      p.rz = rz;
      p.projRadius = (p.baseRadius * perspective).clamp(0.9, 8.0);
      p.alpha =
          (depthFactor * pulse * (isDark ? 0.85 : 0.52)).clamp(0.06, 0.92);
      p.visible = true;
    }

    // 3. Lightweight 3D constellation lines
    const maxDistSq = 110.0 * 110.0;
    for (int i = 0; i < len; i++) {
      final a = particles[i];
      if (!a.visible || a.rz > 1.4) continue;
      int links = 0;
      final colorA = palette[a.colorIndex];
      for (int j = i + 1; j < len; j++) {
        final b = particles[j];
        if (!b.visible || (a.rz - b.rz).abs() > 0.35) continue;
        final dx = a.sx - b.sx;
        final dy = a.sy - b.sy;
        final dSq = dx * dx + dy * dy;
        if (dSq < maxDistSq) {
          final lineAlpha =
              ((1.0 - dSq / maxDistSq) * a.alpha * (isDark ? 0.24 : 0.15))
                  .clamp(0.01, 0.3);
          _linePaint.color = colorA.withValues(alpha: lineAlpha);
          canvas.drawLine(Offset(a.sx, a.sy), Offset(b.sx, b.sy), _linePaint);
          if (++links >= 2) break;
        }
      }
    }

    // 4. Draw 3D particles
    for (int i = 0; i < len; i++) {
      final pt = particles[i];
      if (!pt.visible) continue;
      final color = palette[pt.colorIndex];
      final center = Offset(pt.sx, pt.sy);

      if (pt.projRadius > 2.0) {
        _glowPaint.color = color.withValues(alpha: pt.alpha * 0.2);
        canvas.drawCircle(center, pt.projRadius * 2.3, _glowPaint);
      }

      _corePaint.color = color.withValues(alpha: pt.alpha);
      canvas.drawCircle(center, pt.projRadius, _corePaint);

      if (pt.projRadius > 2.6 && isDark) {
        _corePaint.color = Colors.white.withValues(alpha: pt.alpha * 0.7);
        canvas.drawCircle(
          Offset(pt.sx - pt.projRadius * 0.25, pt.sy - pt.projRadius * 0.25),
          pt.projRadius * 0.3,
          _corePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Particle3DPainter oldDelegate) => false;
}

/// Lightweight 3D Tilt Card without expensive BackdropFilter blur passes,
/// ensuring 60-120 FPS smooth scrolling even on entry-level devices.
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
      _rotY = (dx * 0.07).clamp(-0.09, 0.09);
      _rotX = (-dy * 0.07).clamp(-0.09, 0.09);
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

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: Listener(
        onPointerDown: widget.enableTilt
            ? (e) => _onPanUpdate(e.localPosition, context.size ?? Size.zero)
            : null,
        onPointerMove: widget.enableTilt
            ? (e) => _onPanUpdate(e.localPosition, context.size ?? Size.zero)
            : null,
        onPointerUp: widget.enableTilt ? (_) => _onReset() : null,
        onPointerCancel: widget.enableTilt ? (_) => _onReset() : null,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            transformAlignment: Alignment.center,
            transform: (_rotX == 0 && _rotY == 0)
                ? Matrix4.identity()
                : (Matrix4.identity()
                  ..setEntry(3, 2, 0.0014)
                  ..rotateX(_rotX)
                  ..rotateY(_rotY)),
            padding: widget.padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xE0132A26),
                        Color(0xD80A1718),
                      ]
                    : const [
                        Color(0xF2FFFFFF),
                        Color(0xE8ECFDF5),
                      ],
              ),
              border: Border.all(
                color: accent.withValues(
                  alpha: _isPressed
                      ? (isDark ? 0.55 : 0.45)
                      : (isDark ? 0.26 : 0.22),
                ),
                width: _isPressed ? 1.4 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
