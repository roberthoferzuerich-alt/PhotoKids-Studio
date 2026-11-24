import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:photokids_studio/domain/entities/editor_models.dart';

class PhotoFramePainter extends CustomPainter {
  final PhotoFrameType frameType;
  final double borderWidth;

  PhotoFramePainter({
    required this.frameType,
    this.borderWidth = 24.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (frameType == PhotoFrameType.none) return;

    switch (frameType) {
      case PhotoFrameType.unicorn:
        _drawUnicornFrame(canvas, size);
        break;
      case PhotoFrameType.space:
        _drawSpaceFrame(canvas, size);
        break;
      case PhotoFrameType.beach:
        _drawBeachFrame(canvas, size);
        break;
      case PhotoFrameType.birthday:
        _drawBirthdayFrame(canvas, size);
        break;
      case PhotoFrameType.nature:
        _drawNatureFrame(canvas, size);
        break;
      case PhotoFrameType.comic:
        _drawComicFrame(canvas, size);
        break;
      case PhotoFrameType.none:
        break;
    }
  }

  void _drawUnicornFrame(Canvas canvas, Size size) {
    // 1. Rainbow Gradient Border
    final rect = Offset.zero & size;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFB3BA),
          Color(0xFFFFDFBA),
          Color(0xFFFFFFBA),
          Color(0xFFBAFFC9),
          Color(0xFFBAE1FF),
          Color(0xFFE8BAFF),
          Color(0xFFFFB3BA),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth / 2, borderWidth / 2, size.width - borderWidth, size.height - borderWidth),
      const Radius.circular(20),
    );
    canvas.drawRRect(rrect, borderPaint);

    // 2. Corner Sparkles & Clouds
    _drawSparkle(canvas, const Offset(30, 30), 16, const Color(0xFFFFD700));
    _drawSparkle(canvas, Offset(size.width - 30, 30), 18, const Color(0xFFFF69B4));
    _drawSparkle(canvas, Offset(30, size.height - 30), 18, const Color(0xFF00E5FF));
    _drawSparkle(canvas, Offset(size.width - 30, size.height - 30), 16, const Color(0xFFFFD700));

    // Mid sparkles
    _drawSparkle(canvas, Offset(size.width / 2, 14), 12, Colors.white);
    _drawSparkle(canvas, Offset(size.width / 2, size.height - 14), 12, Colors.white);
    _drawSparkle(canvas, Offset(14, size.height / 2), 12, Colors.pinkAccent);
    _drawSparkle(canvas, Offset(size.width - 14, size.height / 2), 12, Colors.purpleAccent);

    // Cute Stars along the edges
    _drawStar(canvas, const Offset(70, 14), 8, Colors.amber);
    _drawStar(canvas, Offset(size.width - 70, 14), 8, Colors.pinkAccent);
    _drawStar(canvas, Offset(70, size.height - 14), 8, const Color(0xFF40C4FF));
    _drawStar(canvas, Offset(size.width - 70, size.height - 14), 8, Colors.amber);
  }

  void _drawSpaceFrame(Canvas canvas, Size size) {
    // 1. Cosmic Gradient Border
    final rect = Offset.zero & size;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = const LinearGradient(
        colors: [Color(0xFF190061), Color(0xFF240046), Color(0xFF0F3460), Color(0xFF190061)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth / 2, borderWidth / 2, size.width - borderWidth, size.height - borderWidth),
      const Radius.circular(16),
    );
    canvas.drawRRect(rrect, borderPaint);

    // Glowing rim
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFF00F5D4);
    canvas.drawRRect(rrect, rimPaint);

    // Planets and stars in corners
    _drawPlanet(canvas, const Offset(24, 24), 14, Colors.deepOrange, Colors.amber);
    _drawPlanet(canvas, Offset(size.width - 24, size.height - 24), 12, Colors.tealAccent, Colors.cyan);
    _drawCrescentMoon(canvas, Offset(size.width - 24, 24), 12, Colors.amberAccent);

    // Stars along edges
    final starOffsets = [
      Offset(size.width * 0.25, 12),
      Offset(size.width * 0.5, 12),
      Offset(size.width * 0.75, 12),
      Offset(size.width * 0.25, size.height - 12),
      Offset(size.width * 0.5, size.height - 12),
      Offset(size.width * 0.75, size.height - 12),
      Offset(12, size.height * 0.35),
      Offset(12, size.height * 0.65),
      Offset(size.width - 12, size.height * 0.35),
      Offset(size.width - 12, size.height * 0.65),
    ];
    for (int i = 0; i < starOffsets.length; i++) {
      _drawStar(canvas, starOffsets[i], i % 2 == 0 ? 7 : 5, i % 3 == 0 ? Colors.cyanAccent : Colors.white);
    }
  }

  void _drawBeachFrame(Canvas canvas, Size size) {
    // 1. Ocean Turquoise & Golden Sand Gradient
    final rect = Offset.zero & size;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = const LinearGradient(
        colors: [Color(0xFF0077B6), Color(0xFF00B4D8), Color(0xFFFFE6A7), Color(0xFFFFB703)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth / 2, borderWidth / 2, size.width - borderWidth, size.height - borderWidth),
      const Radius.circular(18),
    );
    canvas.drawRRect(rrect, borderPaint);

    // Sun in top right corner
    final sunCenter = Offset(size.width - 22, 22);
    final sunPaint = Paint()..color = const Color(0xFFFFD166);
    canvas.drawCircle(sunCenter, 14, sunPaint);
    // Sun rays
    final rayPaint = Paint()
      ..color = const Color(0xFFFF9E00)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      final p1 = sunCenter + Offset(math.cos(angle) * 16, math.sin(angle) * 16);
      final p2 = sunCenter + Offset(math.cos(angle) * 22, math.sin(angle) * 22);
      canvas.drawLine(p1, p2, rayPaint);
    }

    // Starfish in bottom left corner
    _drawStar(canvas, Offset(24, size.height - 24), 14, const Color(0xFFFF5964));

    // Wave ripples along top and bottom
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.white70;

    for (double x = 40; x < size.width - 40; x += 30) {
      final path = Path()
        ..moveTo(x, 12)
        ..quadraticBezierTo(x + 7, 6, x + 15, 12)
        ..quadraticBezierTo(x + 22, 18, x + 30, 12);
      canvas.drawPath(path, wavePaint);
    }
  }

  void _drawBirthdayFrame(Canvas canvas, Size size) {
    // 1. Festive Yellow & Pink Border
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth / 2, borderWidth / 2, size.width - borderWidth, size.height - borderWidth),
      const Radius.circular(20),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF3366), Color(0xFFFFD166), Color(0xFF06D6A0), Color(0xFF118AB2)],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(rrect, borderPaint);

    // Bunting Pennants across top
    final colors = [Colors.redAccent, Colors.yellowAccent, Colors.lightGreenAccent, Colors.lightBlueAccent, Colors.pinkAccent];
    int colorIdx = 0;
    for (double x = 20; x < size.width - 40; x += 22) {
      final flagPath = Path()
        ..moveTo(x, 4)
        ..lineTo(x + 20, 4)
        ..lineTo(x + 10, 20)
        ..close();
      final flagPaint = Paint()..color = colors[colorIdx % colors.length];
      canvas.drawPath(flagPath, flagPaint);
      colorIdx++;
    }

    // Balloons in corners
    _drawBalloon(canvas, const Offset(20, 32), const Color(0xFFFF4D6D));
    _drawBalloon(canvas, Offset(size.width - 20, size.height - 32), const Color(0xFF4EA8DE));

    // Confetti dots
    final confettiColors = [Colors.white, Colors.yellow, Colors.cyanAccent, Colors.purpleAccent, Colors.orange];
    for (int i = 0; i < 18; i++) {
      final dotOffset = Offset(
        15 + (i * 47) % (size.width - 30),
        size.height - 12 + (i % 2 == 0 ? -3 : 3),
      );
      final dotPaint = Paint()..color = confettiColors[i % confettiColors.length];
      canvas.drawCircle(dotOffset, (i % 3) + 2.5, dotPaint);
    }
  }

  void _drawNatureFrame(Canvas canvas, Size size) {
    // 1. Fresh green foliage border
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth / 2, borderWidth / 2, size.width - borderWidth, size.height - borderWidth),
      const Radius.circular(22),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = const Color(0xFF52B788);
    canvas.drawRRect(rrect, borderPaint);

    // Cute Flower Blossoms at 4 corners
    _drawFlower(canvas, const Offset(24, 24), const Color(0xFFFF70A6), Colors.yellow);
    _drawFlower(canvas, Offset(size.width - 24, 24), const Color(0xFFFF9770), Colors.white);
    _drawFlower(canvas, Offset(24, size.height - 24), const Color(0xFF70D6FF), Colors.yellow);
    _drawFlower(canvas, Offset(size.width - 24, size.height - 24), const Color(0xFFFFD670), Colors.redAccent);

    // Cute Leaves along edges
    for (double x = 60; x < size.width - 60; x += 45) {
      _drawLeaf(canvas, Offset(x, 12), true);
      _drawLeaf(canvas, Offset(x + 20, size.height - 12), false);
    }

    // Ladybug in bottom right
    _drawLadybug(canvas, Offset(size.width - 60, size.height - 12));
  }

  void _drawComicFrame(Canvas canvas, Size size) {
    // 1. Thick Black Comic Border
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth / 2, borderWidth / 2, size.width - borderWidth, size.height - borderWidth),
      const Radius.circular(12),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = Colors.black;
    canvas.drawRRect(rrect, borderPaint);

    // Inner bright yellow accent line
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(borderWidth - 3, borderWidth - 3, size.width - (borderWidth * 2 - 6), size.height - (borderWidth * 2 - 6)),
      const Radius.circular(8),
    );
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = const Color(0xFFFFE600);
    canvas.drawRRect(innerRRect, innerPaint);

    // Halftone / Dots along border
    final dotPaint = Paint()..color = const Color(0xFFFF0055);
    for (double x = 12; x < size.width - 12; x += 18) {
      canvas.drawCircle(Offset(x, 10), 3.5, dotPaint);
      canvas.drawCircle(Offset(x, size.height - 10), 3.5, dotPaint);
    }

    // Action Star in top left
    _drawStar(canvas, const Offset(24, 24), 16, const Color(0xFFFFE600));
    _drawStar(canvas, Offset(size.width - 24, size.height - 24), 16, const Color(0xFF00F5D4));
  }

  // --- Helper Drawing Primitives ---

  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);

    final paint = Paint()..color = color;
    canvas.drawPath(path, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    const int points = 5;
    final double innerRadius = radius * 0.45;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * math.pi / points) - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawPlanet(Canvas canvas, Offset center, double radius, Color color, Color ringColor) {
    canvas.drawCircle(center, radius, Paint()..color = color);
    final ringPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: radius * 3.0, height: radius * 0.8),
      ringPaint,
    );
  }

  void _drawCrescentMoon(Canvas canvas, Offset center, double radius, Color color) {
    final moonPath = Path()
      ..addArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, math.pi)
      ..arcToPoint(
        Offset(center.dx, center.dy - radius),
        radius: Radius.circular(radius * 1.3),
        clockwise: false,
      );
    canvas.drawPath(moonPath, Paint()..color = color);
  }

  void _drawBalloon(Canvas canvas, Offset center, Color color) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 18, height: 24),
      Paint()..color = color,
    );
    final knotPath = Path()
      ..moveTo(center.dx - 3, center.dy + 12)
      ..lineTo(center.dx + 3, center.dy + 12)
      ..lineTo(center.dx, center.dy + 16)
      ..close();
    canvas.drawPath(knotPath, Paint()..color = color);
  }

  void _drawFlower(Canvas canvas, Offset center, Color petalColor, Color centerColor) {
    final petalPaint = Paint()..color = petalColor;
    for (int i = 0; i < 5; i++) {
      final angle = i * (2 * math.pi / 5);
      final petalCenter = center + Offset(math.cos(angle) * 8, math.sin(angle) * 8);
      canvas.drawCircle(petalCenter, 5.5, petalPaint);
    }
    canvas.drawCircle(center, 4.5, Paint()..color = centerColor);
  }

  void _drawLeaf(Canvas canvas, Offset center, bool pointUp) {
    final path = Path()
      ..moveTo(center.dx - 8, center.dy)
      ..quadraticBezierTo(center.dx, center.dy + (pointUp ? -6 : 6), center.dx + 8, center.dy)
      ..quadraticBezierTo(center.dx, center.dy + (pointUp ? 4 : -4), center.dx - 8, center.dy);
    canvas.drawPath(path, Paint()..color = const Color(0xFF2D6A4F));
  }

  void _drawLadybug(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 6, Paint()..color = Colors.red);
    canvas.drawCircle(center + const Offset(0, -5), 3, Paint()..color = Colors.black);
    final spotPaint = Paint()..color = Colors.black;
    canvas.drawCircle(center + const Offset(-2, -1), 1.2, spotPaint);
    canvas.drawCircle(center + const Offset(2, -1), 1.2, spotPaint);
    canvas.drawCircle(center + const Offset(-2, 2), 1.2, spotPaint);
    canvas.drawCircle(center + const Offset(2, 2), 1.2, spotPaint);
  }

  @override
  bool shouldRepaint(covariant PhotoFramePainter oldDelegate) {
    return oldDelegate.frameType != frameType || oldDelegate.borderWidth != borderWidth;
  }
}
