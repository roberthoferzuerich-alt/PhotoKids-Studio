import 'package:flutter/material.dart';

enum CropAspectRatio {
  free,
  square1x1,
  ratio4x3,
  ratio16x9,
  ratio9x16,
  ratio3x2,
  ratio2x1,
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
      case CropAspectRatio.ratio9x16:
        return '9:16 Story/Reels';
      case CropAspectRatio.ratio3x2:
        return '3:2 Foto';
      case CropAspectRatio.ratio2x1:
        return '2:1 Banner';
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
      case CropAspectRatio.ratio9x16:
        return 9.0 / 16.0;
      case CropAspectRatio.ratio3x2:
        return 3.0 / 2.0;
      case CropAspectRatio.ratio2x1:
        return 2.0 / 1.0;
    }
  }
}

/// Standard Web & Social Media Photo Sizes (2026 Standards)
class WebPhotoPreset {
  final String id;
  final String title;
  final String subtitle;
  final int width;
  final int height;
  final String iconEmoji;
  final CropAspectRatio cropRatio;
  final String category;

  const WebPhotoPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.width,
    required this.height,
    required this.iconEmoji,
    required this.cropRatio,
    required this.category,
  });

  double get aspectRatio => width / height;
  String get resolutionLabel => '$width × $height px';
}

class WebPhotoSizes {
  static const List<WebPhotoPreset> standardPresets = [
    WebPhotoPreset(
      id: 'web_fhd',
      title: 'Web Full HD',
      subtitle: 'Standard für Websites, Desktop-Screens & Slider',
      width: 1920,
      height: 1080,
      iconEmoji: '🖥️',
      cropRatio: CropAspectRatio.ratio16x9,
      category: 'Website',
    ),
    WebPhotoPreset(
      id: 'web_blog',
      title: 'Blog & Social Sharing (OG)',
      subtitle: 'OpenGraph Vorschau für WhatsApp, Facebook & X',
      width: 1200,
      height: 630,
      iconEmoji: '📰',
      cropRatio: CropAspectRatio.ratio16x9,
      category: 'Social Media',
    ),
    WebPhotoPreset(
      id: 'web_insta_square',
      title: 'Instagram Post / Web Quadrat',
      subtitle: 'Klassisches 1:1 Quadrat für Feeds & Profile',
      width: 1080,
      height: 1080,
      iconEmoji: '📷',
      cropRatio: CropAspectRatio.square1x1,
      category: 'Social Media',
    ),
    WebPhotoPreset(
      id: 'web_story',
      title: 'Story / Status / Reel (9:16)',
      subtitle: 'Vertikales Vollbild für Insta Story & WhatsApp Status',
      width: 1080,
      height: 1920,
      iconEmoji: '📱',
      cropRatio: CropAspectRatio.ratio9x16,
      category: 'Social Media',
    ),
    WebPhotoPreset(
      id: 'web_photo_standard',
      title: 'Standard Web-Foto (3:2)',
      subtitle: 'Optimiert für Web-Galerien & Fotoblogs',
      width: 1200,
      height: 800,
      iconEmoji: '🖼️',
      cropRatio: CropAspectRatio.ratio3x2,
      category: 'Website',
    ),
    WebPhotoPreset(
      id: 'web_banner',
      title: 'Webseiten Header-Banner',
      subtitle: 'Panorama-Banner für Kopfbereiche (2:1)',
      width: 1200,
      height: 600,
      iconEmoji: '🏷️',
      cropRatio: CropAspectRatio.ratio2x1,
      category: 'Website',
    ),
    WebPhotoPreset(
      id: 'web_thumbnail',
      title: 'Web Thumbnail (Schnell-Ladezeit)',
      subtitle: 'Kompaktes Vorschaubild für schnelle Performance',
      width: 400,
      height: 400,
      iconEmoji: '🔍',
      cropRatio: CropAspectRatio.square1x1,
      category: 'Website',
    ),
    WebPhotoPreset(
      id: 'web_avatar',
      title: 'Profilbild / Avatar',
      subtitle: 'Optimale Größe für Profil-Icons',
      width: 500,
      height: 500,
      iconEmoji: '👤',
      cropRatio: CropAspectRatio.square1x1,
      category: 'Social Media',
    ),
  ];
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
  double rotation;
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
  double rotation;

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
