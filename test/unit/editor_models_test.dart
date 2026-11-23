import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:denis_phote_world/domain/entities/editor_models.dart';

void main() {
  group('Editor Models Unit Tests', () {
    test('CropAspectRatio numeric ratios match photographic standards', () {
      expect(CropAspectRatio.free.numericRatio, isNull);
      expect(CropAspectRatio.square1x1.numericRatio, equals(1.0));
      expect(CropAspectRatio.ratio4x3.numericRatio, closeTo(1.333, 0.01));
      expect(CropAspectRatio.ratio16x9.numericRatio, closeTo(1.777, 0.01));
      expect(CropAspectRatio.ratio3x2.numericRatio, equals(1.5));
    });

    test('DrawingStroke paint configuration works for pen vs eraser', () {
      final penStroke = DrawingStroke(
        points: const [Offset(0, 0), Offset(10, 10)],
        color: Colors.red,
        strokeWidth: 5.0,
        toolType: DrawingToolType.pen,
      );

      final eraserStroke = DrawingStroke(
        points: const [Offset(0, 0), Offset(10, 10)],
        color: Colors.transparent,
        strokeWidth: 10.0,
        toolType: DrawingToolType.eraser,
      );

      expect(penStroke.paint.color.value, equals(Colors.red.value));
      expect(penStroke.paint.strokeWidth, equals(5.0));
      expect(eraserStroke.paint.blendMode, equals(BlendMode.clear));
    });

    test('ColorAdjustmentParams copyWith works as expected', () {
      const initial = ColorAdjustmentParams();
      expect(initial.brightness, equals(0.0));
      expect(initial.contrast, equals(1.0));

      final adjusted = initial.copyWith(brightness: 0.2, contrast: 1.4);
      expect(adjusted.brightness, equals(0.2));
      expect(adjusted.contrast, equals(1.4));
      expect(adjusted.saturation, equals(1.0));
    });
  });
}
