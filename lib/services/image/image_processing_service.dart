import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageProcessInput {
  final Uint8List imageBytes;
  final int? cropX;
  final int? cropY;
  final int? cropWidth;
  final int? cropHeight;
  final int? resizeWidth;
  final int? resizeHeight;
  final int rotateDegrees;
  final bool flipHorizontal;
  final bool flipVertical;
  final double brightness; // -1.0 to 1.0
  final double contrast;   // 0.0 to 2.0
  final double saturation; // 0.0 to 2.0
  final String? filterPreset;

  ImageProcessInput({
    required this.imageBytes,
    this.cropX,
    this.cropY,
    this.cropWidth,
    this.cropHeight,
    this.resizeWidth,
    this.resizeHeight,
    this.rotateDegrees = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.filterPreset,
  });
}

class ImageProcessingService {
  /// Executes heavy image manipulation in a background Isolate using compute()
  static Future<Uint8List> processImage(ImageProcessInput input) async {
    return await compute(_isolateProcessImage, input);
  }

  /// Thumbnail generation in background isolate
  static Future<Uint8List> generateThumbnail(Uint8List imageBytes, {int targetSize = 250}) async {
    return await compute(_isolateGenerateThumbnail, {
      'bytes': imageBytes,
      'size': targetSize,
    });
  }

  static Uint8List _isolateProcessImage(ImageProcessInput input) {
    img.Image? image = img.decodeImage(input.imageBytes);
    if (image == null) return input.imageBytes;

    // 1. Crop
    if (input.cropWidth != null && input.cropHeight != null && input.cropWidth! > 0 && input.cropHeight! > 0) {
      final x = input.cropX ?? 0;
      final y = input.cropY ?? 0;
      image = img.copyCrop(image, x: x, y: y, width: input.cropWidth!, height: input.cropHeight!);
    }

    // 2. Resize
    if (input.resizeWidth != null && input.resizeHeight != null) {
      image = img.copyResize(image, width: input.resizeWidth!, height: input.resizeHeight!);
    }

    // 3. Rotation
    if (input.rotateDegrees % 360 != 0) {
      image = img.copyRotate(image, angle: input.rotateDegrees.toDouble());
    }

    // 4. Flip
    if (input.flipHorizontal) {
      image = img.copyFlip(image, direction: img.FlipDirection.horizontal);
    }
    if (input.flipVertical) {
      image = img.copyFlip(image, direction: img.FlipDirection.vertical);
    }

    // 5. Brightness & Contrast
    if (input.brightness != 0.0 || input.contrast != 1.0) {
      image = img.adjustColor(
        image,
        brightness: 1.0 + input.brightness,
        contrast: input.contrast,
        saturation: input.saturation,
      );
    }

    // 6. Filter Presets
    if (input.filterPreset != null) {
      switch (input.filterPreset!.toLowerCase()) {
        case 'kidspop':
          image = img.adjustColor(image, saturation: 1.5, contrast: 1.2);
          break;
        case 'vintage':
          image = img.sepia(image, amount: 0.8);
          break;
        case 'bw':
        case 'blackandwhite':
          image = img.grayscale(image);
          break;
        case 'cool':
          image = img.colorOffset(image, blue: 30, red: -15);
          break;
        case 'warm':
          image = img.colorOffset(image, red: 35, blue: -20);
          break;
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 90));
  }

  static Uint8List _isolateGenerateThumbnail(Map<String, dynamic> params) {
    final bytes = params['bytes'] as Uint8List;
    final size = params['size'] as int;

    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    final thumbnail = img.copyResize(
      image,
      width: image.width > image.height ? size : null,
      height: image.height >= image.width ? size : null,
    );

    return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 75));
  }
}
