import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:photokids_studio/domain/entities/photo_entity.dart';

class AiImageGeneratorService {
  static const Map<String, String> styleModifiers = {
    'Pixar 3D 🎨': '3d pixar disney animation style, cute, vibrant warm lighting, highly detailed 3d render, joyful, kid friendly, masterpiece',
    'Zeichentrick 🖌️': 'colorful vibrant cartoon illustration, charming children storybook art, expressive, whimsical, clean outlines',
    'Zauberhaft ✨': 'magical fantasy fairy tale style, glowing sparkles, enchanted atmosphere, pastel dreamy colors, beautiful',
    'Foto 📷': 'vibrant colorful photography, crisp clean lighting, cheerful, high resolution, stunning',
  };

  /// Generiert ein Bild mit automatischem Retry, Browser-User-Agent und Modell-Fallback.
  static Future<PhotoEntity?> generateImage({
    required String prompt,
    String style = 'Pixar 3D 🎨',
  }) async {
    if (prompt.trim().isEmpty) return null;

    final modifier = styleModifiers[style] ?? styleModifiers.values.first;
    final enhancedPrompt = '${prompt.trim()}, $modifier';

    // 3 automatische Versuche mit verschiedenen Modellen und optimierter Auflösung für maximale Zuverlässigkeit
    final attempts = [
      {'model': 'flux', 'width': 768, 'height': 768},
      {'model': 'turbo', 'width': 768, 'height': 768},
      {'model': 'turbo', 'width': 512, 'height': 512},
    ];

    Uint8List? imageBytes;
    int resolvedWidth = 768;
    int resolvedHeight = 768;

    for (int i = 0; i < attempts.length; i++) {
      final config = attempts[i];
      final model = config['model'] as String;
      final w = config['width'] as int;
      final h = config['height'] as int;
      final randomSeed = Random().nextInt(999999);

      final urlString = 'https://image.pollinations.ai/prompt/${Uri.encodeComponent(enhancedPrompt)}'
          '?width=$w&height=$h&seed=$randomSeed&model=$model&nologo=true';

      debugPrint('AI Generation Versuch ${i + 1}/${attempts.length} mit $model ($w x $h)...');

      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 12);

        final request = await client.getUrl(Uri.parse(urlString)).timeout(const Duration(seconds: 15));

        // Browser User-Agent setzen, damit Cloudflare/CDN den Request nicht drosselt oder blockiert
        request.headers.set(
          'User-Agent',
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        );
        request.headers.set('Accept', 'image/jpeg,image/png,image/*');

        final response = await request.close().timeout(const Duration(seconds: 25));

        if (response.statusCode == 200) {
          final bytes = await consolidateHttpClientResponseBytes(response);
          // Validierung: Echte Bilddaten haben JPEG (0xFF) oder PNG (0x89) Magic Bytes
          if (bytes.length > 5000 && (bytes[0] == 0xFF || bytes[0] == 0x89)) {
            imageBytes = bytes;
            resolvedWidth = w;
            resolvedHeight = h;
            debugPrint('AI Generation erfolgreich bei Versuch ${i + 1}!');
            break;
          } else {
            debugPrint('AI Versuch ${i + 1}: Ungültige Bilddaten empfangen (Länge: ${bytes.length})');
          }
        } else {
          debugPrint('Pollinations AI Versuch ${i + 1} fehlgeschlagen mit HTTP-Status: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('Pollinations AI Versuch ${i + 1} Exception: $e');
      }

      // Kurze Pause vor dem nächsten automatischen Versuch
      if (i < attempts.length - 1) {
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }

    if (imageBytes == null || imageBytes.isEmpty) {
      return null;
    }

    // Speicherpfad im permanenten App-Dokumentenverzeichnis
    final docsDir = await getApplicationDocumentsDirectory();
    final aiDir = Directory(p.join(docsDir.path, 'ai_generated_photos'));
    if (!await aiDir.exists()) {
      await aiDir.create(recursive: true);
    }

    final photoId = const Uuid().v4();
    final safeName = prompt.trim().replaceAll(RegExp(r'[^\w\s\u00C0-\u017F-]'), '').replaceAll(' ', '_');
    final cleanFileName = '${safeName.isNotEmpty ? safeName.substring(0, min(safeName.length, 30)) : 'Zauberbild'}_$photoId.jpg';
    final filePath = p.join(aiDir.path, cleanFileName);

    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    return PhotoEntity(
      id: photoId,
      filePath: filePath,
      fileName: cleanFileName,
      fileExtension: 'jpg',
      fileSizeBytes: imageBytes.length,
      width: resolvedWidth,
      height: resolvedHeight,
      dateTaken: DateTime.now(),
      dateAdded: DateTime.now(),
      category: 'KI-Zauber 🪄',
      tags: ['ki', 'zauber', style.split(' ').first.toLowerCase()],
    );
  }
}
