import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiCelebration extends StatefulWidget {
  final Widget child;
  final bool isPlaying;
  final VoidCallback? onFinished;

  const ConfettiCelebration({
    super.key,
    required this.child,
    required this.isPlaying,
    this.onFinished,
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished?.call();
      }
    });

    if (widget.isPlaying) {
      _startCelebration();
    }
  }

  @override
  void didUpdateWidget(covariant ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    _particles.clear();
    final colors = [
      const Color(0xFFFF5964),
      const Color(0xFFFFE74C),
      const Color(0xFF06D6A0),
      const Color(0xFF118AB2),
      const Color(0xFFFF70A6),
      const Color(0xFF9D4EDD),
      const Color(0xFFFF9E00),
      Colors.white,
    ];

    for (int i = 0; i < 70; i++) {
      _particles.add(
        _ConfettiParticle(
          x: 0.1 + _random.nextDouble() * 0.8,
          y: -0.1 - _random.nextDouble() * 0.2,
          vx: (_random.nextDouble() - 0.5) * 0.7,
          vy: 0.6 + _random.nextDouble() * 1.0,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 8,
          size: 6.0 + _random.nextDouble() * 8.0,
          color: colors[_random.nextInt(colors.length)],
          isStar: i % 3 == 0,
        ),
      );
    }

    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_controller.isAnimating)
          IgnorePointer(
            child: CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _controller.value,
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final Color color;
  final bool isStar;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.isStar,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y + p.vy * progress) * size.height;
      final currentX = (p.x + p.vx * progress + math.sin(progress * 6 + p.x * 10) * 0.05) * size.width;
      final currentRotation = p.rotation + p.rotationSpeed * progress;
      final alpha = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);

      if (p.isStar) {
        _drawStar(canvas, p.size, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    const int points = 5;
    final double innerRadius = radius * 0.45;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * math.pi / points) - (math.pi / 2);
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
