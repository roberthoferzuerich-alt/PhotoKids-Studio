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
      expect(CropAspectRatio.ratio9x16.numericRatio, closeTo(0.5625, 0.01));
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

    test('WebPhotoSizes contains standard modern web resolutions', () {
      expect(WebPhotoSizes.standardPresets.isNotEmpty, isTrue);

      final fhd = WebPhotoSizes.standardPresets.firstWhere((p) => p.id == 'web_fhd');
      expect(fhd.width, equals(1920));
      expect(fhd.height, equals(1080));
      expect(fhd.resolutionLabel, equals('1920 × 1080 px'));

      final insta = WebPhotoSizes.standardPresets.firstWhere((p) => p.id == 'web_insta_square');
      expect(insta.width, equals(1080));
      expect(insta.height, equals(1080));
      expect(insta.aspectRatio, equals(1.0));

      final story = WebPhotoSizes.standardPresets.firstWhere((p) => p.id == 'web_story');
      expect(story.width, equals(1080));
      expect(story.height, equals(1920));
    });

    test('PhotoFramePresets contains all magical kid frame presets', () {
      expect(PhotoFramePresets.all.isNotEmpty, isTrue);
      final types = PhotoFramePresets.all.map((f) => f.type).toList();
      expect(types, contains(PhotoFrameType.none));
      expect(types, contains(PhotoFrameType.unicorn));
      expect(types, contains(PhotoFrameType.space));
      expect(types, contains(PhotoFrameType.beach));
      expect(types, contains(PhotoFrameType.birthday));
      expect(types, contains(PhotoFrameType.nature));
      expect(types, contains(PhotoFrameType.comic));

      final unicorn = PhotoFramePresets.all.firstWhere((f) => f.type == PhotoFrameType.unicorn);
      expect(unicorn.emoji, equals('🦄'));
      expect(unicorn.gradientColors.isNotEmpty, isTrue);
    });

    test('TextOverlay supports speech bubble types', () {
      final bubble = TextOverlay(
        id: '123',
        text: 'BÄM! 💥',
        position: const Offset(10, 20),
        bubbleType: SpeechBubbleType.comic,
        bubbleColor: Colors.yellow,
      );

      expect(bubble.text, equals('BÄM! 💥'));
      expect(bubble.bubbleType, equals(SpeechBubbleType.comic));
      expect(bubble.bubbleColor, equals(Colors.yellow));
    });
  });
}
