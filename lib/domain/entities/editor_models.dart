import 'package:flutter/material.dart';

enum CropAspectRatio {
  free,
  square1x1,
  ratio4x3,
  ratio16x9,
  ratio3x2,
}

extension CropAspectRatioExt on CropAspectRatio {
  String get label {
    switch (this) {
      case CropAspectRatio.free:
        return 'Frei';
      case CropAspectRatio.square1x1:
        return '1:1 Quadrat';
      case CropAspectRatio.ratio4x3:
        return '4:3 Standard';
      case CropAspectRatio.ratio16x9:
        return '16:9 Breitbild';
      case CropAspectRatio.ratio3x2:
        return '3:2 Foto';
    }
  }

  double? get numericRatio {
    switch (this) {
      case CropAspectRatio.free:
        return null;
      case CropAspectRatio.square1x1:
        return 1.0;
      case CropAspectRatio.ratio4x3:
        return 4.0 / 3.0;
      case CropAspectRatio.ratio16x9:
        return 16.0 / 9.0;
      case CropAspectRatio.ratio3x2:
        return 3.0 / 2.0;
    }
  }
}

enum DrawingToolType {
  pen,
  marker,
  brush,
  eraser,
}

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final double opacity;
  final DrawingToolType toolType;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.opacity = 1.0,
    required this.toolType,
  });

  Paint get paint {
    final p = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    if (toolType == DrawingToolType.eraser) {
      p.blendMode = BlendMode.clear;
      p.color = Colors.transparent;
    } else {
      p.color = color.withValues(alpha: opacity);
      p.style = PaintingStyle.stroke;
    }
    return p;
  }
}

class TextOverlay {
  final String id;
  String text;
  Offset position;
  Color color;
  double fontSize;
  double rotation; // Radians
  bool hasShadow;
  String fontFamily;

  TextOverlay({
    required this.id,
    required this.text,
    required this.position,
    this.color = Colors.white,
    this.fontSize = 28.0,
    this.rotation = 0.0,
    this.hasShadow = true,
    this.fontFamily = 'Roboto',
  });
}

class StickerItem {
  final String id;
  final String emojiOrAsset;
  Offset position;
  double scale;
  double rotation; // Radians

  StickerItem({
    required this.id,
    required this.emojiOrAsset,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class ColorAdjustmentParams {
  final double brightness; // -1.0 to 1.0
  final double contrast;   // 0.0 to 2.0 (1.0 = normal)
  final double saturation; // 0.0 to 2.0 (1.0 = normal)
  final double temperature;// -1.0 to 1.0 (warm / cool)
  final double sharpness;  // 0.0 to 2.0

  const ColorAdjustmentParams({
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.temperature = 0.0,
    this.sharpness = 1.0,
  });

  ColorAdjustmentParams copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? temperature,
    double? sharpness,
  }) {
    return ColorAdjustmentParams(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      temperature: temperature ?? this.temperature,
      sharpness: sharpness ?? this.sharpness,
    );
  }
}
