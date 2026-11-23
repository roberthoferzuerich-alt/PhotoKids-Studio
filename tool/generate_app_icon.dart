import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Generate 1024x1024 App Icon for PhotoKids Studio', () async {
    const size = 1024.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

    // 1. App Icon Background Squircle with 3D Gradient
    final bgRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(32, 32, size - 64, size - 64),
      const Radius.circular(220),
    );

    // Deep ambient drop shadow
    final shadowPaint = Paint()
      ..color = const Color(0x55000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48);
    canvas.drawRRect(bgRRect.shift(const Offset(0, 28)), shadowPaint);

    // Background Gradient: Rich Coral Pink to Deep Magenta / Violet
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(64, 64),
        const Offset(size - 64, size - 64),
        [
          const Color(0xFFFF6584),
          const Color(0xFFFF416C),
          const Color(0xFF8A2387),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(bgRRect, bgPaint);

    // Subtle inner border glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = const Color(0x44FFFFFF);
    canvas.drawRRect(bgRRect, glowPaint);

    // 2. Playful Background Sparkles & Confetti Stars
    void drawSparkle(Offset center, double radius, Color color) {
      final path = Path()
        ..moveTo(center.dx, center.dy - radius)
        ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
        ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
        ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
        ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
      canvas.drawPath(path, Paint()..color = color);
    }

    void drawStar(Offset center, double radius, Color color) {
      final path = Path();
      const int points = 5;
      final innerRadius = radius * 0.45;
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

    drawSparkle(const Offset(220, 190), 38, const Color(0xFFFFE066));
    drawSparkle(const Offset(820, 230), 48, Colors.white);
    drawSparkle(const Offset(180, 780), 32, const Color(0xFF64FFDA));
    drawStar(const Offset(840, 740), 36, const Color(0xFFFFD166));
    drawStar(const Offset(760, 160), 24, const Color(0xFFFF9EAA));

    // Floating colorful confetti bubbles
    final confetti = [
      (const Offset(150, 360), 16.0, const Color(0xFFFFE74C)),
      (const Offset(880, 440), 20.0, const Color(0xFF00F5D4)),
      (const Offset(240, 840), 18.0, const Color(0xFFFF9E00)),
      (const Offset(780, 850), 22.0, const Color(0xFFE0AAFF)),
      (const Offset(160, 580), 14.0, Colors.white70),
    ];
    for (final c in confetti) {
      canvas.drawCircle(c.$1, c.$2, Paint()..color = c.$3);
    }

    // 3. Cute 3D Camera Body
    const camLeft = 200.0;
    const camTop = 320.0;
    const camWidth = 624.0;
    const camHeight = 440.0;
    final camRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(camLeft, camTop, camWidth, camHeight),
      const Radius.circular(110),
    );

    // Camera drop shadow
    canvas.drawRRect(
      camRRect.shift(const Offset(0, 32)),
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36),
    );

    // Camera Body Gradient (Vibrant Turquoise / Mint with 3D lighting)
    final camPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(camLeft, camTop),
        const Offset(camLeft + camWidth, camTop + camHeight),
        [
          const Color(0xFF26E5D4),
          const Color(0xFF00C4B4),
          const Color(0xFF00897B),
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRRect(camRRect, camPaint);

    // Camera Top Bevel Highlight
    final highlightPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(camLeft, camTop),
        const Offset(camLeft, camTop + 140),
        [
          const Color(0x66FFFFFF),
          const Color(0x00FFFFFF),
        ],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(camLeft + 12, camTop + 10, camWidth - 24, 120),
        const Radius.circular(90),
      ),
      highlightPaint,
    );

    // Camera Bottom Accent Stripe (Sunny Warm Yellow)
    final stripePath = Path()
      ..addRRect(camRRect);
    canvas.save();
    canvas.clipPath(stripePath);
    final accentPaint = Paint()
      ..color = const Color(0xFFFFD166);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(camLeft, camTop + camHeight - 80, camWidth, 90),
        const Radius.circular(30),
      ),
      accentPaint,
    );
    canvas.restore();

    // 4. Camera Shutter Button (Top Left)
    final shutterRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(camLeft + 70, camTop - 46, 120, 60),
      const Radius.circular(30),
    );
    canvas.drawRRect(
      shutterRRect.shift(const Offset(0, 10)),
      Paint()
        ..color = const Color(0x44000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawRRect(
      shutterRRect,
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(camLeft + 70, camTop - 46),
          const Offset(camLeft + 70, camTop + 14),
          [const Color(0xFFFFE066), const Color(0xFFFF9E00)],
        ),
    );

    // 5. Flash Unit (Top Right)
    final flashRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(camLeft + camWidth - 180, camTop + 40, 96, 68),
      const Radius.circular(32),
    );
    canvas.drawRRect(
      flashRRect,
      Paint()..color = const Color(0xFF1E1430),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(camLeft + camWidth - 170, camTop + 48, 76, 52),
        const Radius.circular(24),
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          const Offset(camLeft + camWidth - 170, camTop + 48),
          const Offset(camLeft + camWidth - 94, camTop + 100),
          [const Color(0xFFFFF9E6), const Color(0xFFFFD54F)],
        ),
    );

    // 6. Viewfinder Dot (Cute friendly circle)
    canvas.drawCircle(
      const Offset(camLeft + 90, camTop + 74),
      18,
      Paint()..color = const Color(0xFF1E1430),
    );
    canvas.drawCircle(
      const Offset(camLeft + 90, camTop + 74),
      10,
      Paint()..color = const Color(0xFF64FFDA),
    );

    // 7. Giant Magical Rainbow Lens (Centerpiece)
    final lensCenter = Offset(camLeft + camWidth / 2, camTop + camHeight / 2 + 10);
    const lensRadius = 168.0;

    // Lens Outer Ring 3D Shadow
    canvas.drawCircle(
      lensCenter + const Offset(0, 20),
      lensRadius + 22,
      Paint()
        ..color = const Color(0x66000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
    );

    // Outer Chrome / Pastel Rim
    canvas.drawCircle(
      lensCenter,
      lensRadius + 20,
      Paint()
        ..shader = ui.Gradient.sweep(
          lensCenter,
          [
            const Color(0xFFFFFFFF),
            const Color(0xFFE0E0E0),
            const Color(0xFFFFFFFF),
            const Color(0xFFBDBDBD),
            const Color(0xFFFFFFFF),
          ],
          [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
    );

    // Dark Lens Barrel
    canvas.drawCircle(
      lensCenter,
      lensRadius,
      Paint()..color = const Color(0xFF1A1528),
    );

    // Rainbow Hologram Gradient Rings
    final rainbowRings = [
      (lensRadius * 0.90, [const Color(0xFFFF5277), const Color(0xFFFFC107)]),
      (lensRadius * 0.74, [const Color(0xFF00C4B4), const Color(0xFF7C4DFF)]),
      (lensRadius * 0.56, [const Color(0xFF118AB2), const Color(0xFF06D6A0)]),
      (lensRadius * 0.38, [const Color(0xFF1E1430), const Color(0xFF0D0A17)]),
    ];

    for (final ring in rainbowRings) {
      canvas.drawCircle(
        lensCenter,
        ring.$1,
        Paint()
          ..shader = ui.Gradient.linear(
            lensCenter - Offset(ring.$1, ring.$1),
            lensCenter + Offset(ring.$1, ring.$1),
            ring.$2,
          ),
      );
    }

    // Lens Deep Center Pupil
    canvas.drawCircle(
      lensCenter,
      lensRadius * 0.28,
      Paint()..color = const Color(0xFF08060E),
    );

    // 8. Lens Glass Glare & Sparkle Reflection
    final glarePath = Path()
      ..addArc(
        Rect.fromCircle(center: lensCenter, radius: lensRadius * 0.82),
        -math.pi * 0.85,
        math.pi * 0.55,
      );
    canvas.drawPath(
      glarePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x99FFFFFF),
    );

    // Star sparkle in lens reflection
    drawSparkle(lensCenter + const Offset(-52, -54), 28, Colors.white);
    canvas.drawCircle(lensCenter + const Offset(48, 48), 12, Paint()..color = const Color(0x66FFFFFF));

    // 9. Playful Artist Touch: Colorful Little Paint Splash at Bottom Right of Camera
    final splashPaint = Paint()..color = const Color(0xFFFF5277);
    canvas.drawCircle(const Offset(camLeft + camWidth - 60, camTop + camHeight - 40), 22, splashPaint);
    canvas.drawCircle(const Offset(camLeft + camWidth - 30, camTop + camHeight - 15), 14, Paint()..color = const Color(0xFFFFD166));
    canvas.drawCircle(const Offset(camLeft + camWidth - 85, camTop + camHeight - 10), 10, Paint()..color = const Color(0xFF00C4B4));

    // Finish picture and encode to PNG
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    // Ensure assets/img directory exists
    final targetDir = Directory('assets/img');
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    final targetFile = File('assets/img/icon.png');
    await targetFile.writeAsBytes(pngBytes);

    expect(targetFile.existsSync(), isTrue);
    expect(targetFile.lengthSync() > 10000, isTrue);
    // ignore: avoid_print
    print('SUCCESS: Created assets/img/icon.png with ${targetFile.lengthSync()} bytes!');
  });
}
