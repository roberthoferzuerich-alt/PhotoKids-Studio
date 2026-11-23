import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:denis_phote_world/domain/entities/album_entity.dart';
import 'package:denis_phote_world/domain/entities/photo_entity.dart';
import 'package:denis_phote_world/domain/repositories/i_album_repository.dart';
import 'package:denis_phote_world/domain/repositories/i_photo_repository.dart';

class SampleDataSeeder {
  static Future<void> seedInitialDataIfNeeded(
    IPhotoRepository photoRepo,
    IAlbumRepository albumRepo,
  ) async {
    if (kIsWeb) {
      try {
        final albums = await albumRepo.getAllAlbums();
        if (albums.isEmpty) {
          final albumUrlaub = AlbumEntity(
            id: 'album_urlaub',
            name: 'Sommerurlaub 🏖️',
            description: 'Strand, Meer und Sonnentage',
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            iconEmoji: '🏖️',
          );
          final albumTiere = AlbumEntity(
            id: 'album_tiere',
            name: 'Tiere & Natur 🐶',
            description: 'Süße Tiere im Zoo und Park',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            iconEmoji: '🐶',
          );
          await albumRepo.createAlbum(albumUrlaub);
          await albumRepo.createAlbum(albumTiere);
        }
      } catch (e) {
        debugPrint('Web album seeding notice: $e');
      }
      return;
    }
    final count = await photoRepo.getTotalPhotoCount();
    if (count > 0) return;
    await forceReSeed(photoRepo, albumRepo);
  }

  static Future<void> forceReSeed(
    IPhotoRepository photoRepo,
    IAlbumRepository albumRepo,
  ) async {
    if (kIsWeb) return;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final sampleDir = Directory(p.join(docsDir.path, 'sample_photos'));
      if (!await sampleDir.exists()) {
        await sampleDir.create(recursive: true);
      }

      // Create default albums if missing
      final albumUrlaub = AlbumEntity(
        id: 'album_urlaub',
        name: 'Sommerurlaub 🏖️',
        description: 'Strand, Meer und Sonnentage',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        iconEmoji: '🏖️',
      );
      final albumTiere = AlbumEntity(
        id: 'album_tiere',
        name: 'Tiere & Natur 🐶',
        description: 'Süße Tiere im Zoo und Park',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        iconEmoji: '🐶',
      );

      await albumRepo.createAlbum(albumUrlaub);
      await albumRepo.createAlbum(albumTiere);

      final samples = [
        {
          'title': 'Sonniger_Strand.jpg',
          'album': 'album_urlaub',
          'cat': 'Urlaub 🏖️',
          'generator': _generateBeachScene,
        },
        {
          'title': 'Mein_Lieblingshund.jpg',
          'album': 'album_tiere',
          'cat': 'Tiere 🐶',
          'generator': _generatePuppyScene,
        },
        {
          'title': 'Regenbogen_Garten.jpg',
          'album': 'album_urlaub',
          'cat': 'Natur 🌸',
          'generator': _generateRainbowScene,
        },
        {
          'title': 'Geburtstags_Kuchen.jpg',
          'album': null,
          'cat': 'Party 🎉',
          'generator': _generateCakeScene,
        },
      ];

      for (int i = 0; i < samples.length; i++) {
        final info = samples[i];
        final filename = info['title'] as String;
        final generator = info['generator'] as img.Image Function();
        final filePath = p.join(sampleDir.path, filename);

        final sampleImage = generator();
        final jpgBytes = Uint8List.fromList(img.encodeJpg(sampleImage, quality: 90));
        final file = File(filePath);
        await file.writeAsBytes(jpgBytes);

        // Check if photo exists to update or insert
        final existing = await photoRepo.searchPhotos(query: filename);
        if (existing.isNotEmpty) {
          final photo = existing.first.copyWith(
            filePath: filePath,
            width: sampleImage.width,
            height: sampleImage.height,
            fileSizeBytes: jpgBytes.length,
          );
          await photoRepo.updatePhoto(photo);
        } else {
          final photo = PhotoEntity(
            id: const Uuid().v4(),
            filePath: filePath,
            fileName: filename,
            fileExtension: 'jpg',
            fileSizeBytes: jpgBytes.length,
            width: sampleImage.width,
            height: sampleImage.height,
            dateTaken: DateTime.now().subtract(Duration(days: i * 2, hours: i * 3)),
            dateAdded: DateTime.now(),
            flag: i == 0 ? PhotoFlag.favorite : PhotoFlag.none,
            albumId: info['album'] as String?,
            category: info['cat'] as String?,
            tags: ['fotokids', 'bunt', 'spaß'],
          );
          await photoRepo.savePhoto(photo);
        }
      }
    } catch (e) {
      debugPrint('Sample data seeding error: $e');
    }
  }

  /// 🏖️ 1. Beach scene with smiling sun, cyan sea and golden beach
  static img.Image _generateBeachScene() {
    final image = img.Image(width: 800, height: 600);
    for (int y = 0; y < 350; y++) {
      final t = y / 350.0;
      final r = (120 * (1 - t) + 180 * t).toInt();
      final g = (200 * (1 - t) + 230 * t).toInt();
      final b = (255 * (1 - t) + 250 * t).toInt();
      img.fillRect(image, x1: 0, y1: y, x2: 799, y2: y, color: img.ColorRgb8(r, g, b));
    }
    img.fillCircle(image, x: 650, y: 120, radius: 85, color: img.ColorRgb8(255, 220, 60));
    img.fillCircle(image, x: 650, y: 120, radius: 70, color: img.ColorRgb8(255, 235, 100));

    for (int y = 350; y < 450; y++) {
      final t = (y - 350) / 100.0;
      final r = (0 * (1 - t) + 30 * t).toInt();
      final g = (180 * (1 - t) + 210 * t).toInt();
      final b = (230 * (1 - t) + 210 * t).toInt();
      img.fillRect(image, x1: 0, y1: y, x2: 799, y2: y, color: img.ColorRgb8(r, g, b));
    }

    for (int x = 0; x < 800; x += 30) {
      img.fillCircle(image, x: x + 15, y: 440, radius: 10, color: img.ColorRgb8(255, 255, 255));
    }

    for (int y = 450; y < 600; y++) {
      final t = (y - 450) / 150.0;
      final r = (255 * (1 - t) + 240 * t).toInt();
      final g = (220 * (1 - t) + 195 * t).toInt();
      final b = (130 * (1 - t) + 120 * t).toInt();
      img.fillRect(image, x1: 0, y1: y, x2: 799, y2: y, color: img.ColorRgb8(r, g, b));
    }

    img.fillCircle(image, x: 220, y: 520, radius: 25, color: img.ColorRgb8(255, 110, 100));
    img.fillCircle(image, x: 220, y: 520, radius: 12, color: img.ColorRgb8(255, 220, 120));

    return image;
  }

  /// 🐶 2. Cute cartoon puppy on meadow
  static img.Image _generatePuppyScene() {
    final image = img.Image(width: 800, height: 600);
    img.fill(image, color: img.ColorRgb8(210, 240, 255));

    img.fillCircle(image, x: 200, y: 700, radius: 360, color: img.ColorRgb8(120, 210, 110));
    img.fillCircle(image, x: 600, y: 700, radius: 380, color: img.ColorRgb8(95, 195, 85));

    const px = 400;
    const py = 320;
    img.fillCircle(image, x: px - 110, y: py - 40, radius: 65, color: img.ColorRgb8(170, 100, 60));
    img.fillCircle(image, x: px + 110, y: py - 40, radius: 65, color: img.ColorRgb8(170, 100, 60));
    img.fillCircle(image, x: px, y: py, radius: 130, color: img.ColorRgb8(235, 175, 115));
    img.fillCircle(image, x: px, y: py + 40, radius: 65, color: img.ColorRgb8(255, 245, 230));

    img.fillCircle(image, x: px - 45, y: py - 20, radius: 20, color: img.ColorRgb8(40, 30, 30));
    img.fillCircle(image, x: px - 40, y: py - 25, radius: 7, color: img.ColorRgb8(255, 255, 255));
    img.fillCircle(image, x: px + 45, y: py - 20, radius: 20, color: img.ColorRgb8(40, 30, 30));
    img.fillCircle(image, x: px + 50, y: py - 25, radius: 7, color: img.ColorRgb8(255, 255, 255));

    img.fillCircle(image, x: px, y: py + 25, radius: 22, color: img.ColorRgb8(40, 30, 30));
    img.fillCircle(image, x: px, y: py + 75, radius: 20, color: img.ColorRgb8(255, 120, 140));

    return image;
  }

  /// 🌈 3. Rainbow scene with fluffy clouds
  static img.Image _generateRainbowScene() {
    final image = img.Image(width: 800, height: 600);
    img.fill(image, color: img.ColorRgb8(215, 240, 255));

    final colors = [
      img.ColorRgb8(255, 80, 100),
      img.ColorRgb8(255, 160, 50),
      img.ColorRgb8(255, 230, 60),
      img.ColorRgb8(100, 220, 110),
      img.ColorRgb8(60, 190, 240),
      img.ColorRgb8(170, 110, 220),
    ];

    const cx = 400;
    const cy = 520;
    int radius = 400;
    for (final col in colors) {
      img.fillCircle(image, x: cx, y: cy, radius: radius, color: col);
      radius -= 26;
    }
    img.fillCircle(image, x: cx, y: cy, radius: radius, color: img.ColorRgb8(215, 240, 255));
    img.fillRect(image, x1: 0, y1: 490, x2: 799, y2: 599, color: img.ColorRgb8(110, 215, 95));

    _drawCloud(image, 140, 480);
    _drawCloud(image, 660, 480);
    _drawCloud(image, 400, 160);

    return image;
  }

  static void _drawCloud(img.Image imgData, int cx, int cy) {
    final col = img.ColorRgb8(255, 255, 255);
    img.fillCircle(imgData, x: cx, y: cy, radius: 45, color: col);
    img.fillCircle(imgData, x: cx - 40, y: cy + 10, radius: 35, color: col);
    img.fillCircle(imgData, x: cx + 40, y: cy + 10, radius: 35, color: col);
    img.fillCircle(imgData, x: cx - 20, y: cy - 20, radius: 30, color: col);
    img.fillCircle(imgData, x: cx + 20, y: cy - 20, radius: 30, color: col);
  }

  /// 🎂 4. Colorful Birthday Cake with Candles & Confetti
  static img.Image _generateCakeScene() {
    final image = img.Image(width: 800, height: 600);
    for (int y = 0; y < 600; y++) {
      final t = y / 600.0;
      final r = (255 * (1 - t) + 250 * t).toInt();
      final g = (235 * (1 - t) + 215 * t).toInt();
      final b = (245 * (1 - t) + 235 * t).toInt();
      img.fillRect(image, x1: 0, y1: y, x2: 799, y2: y, color: img.ColorRgb8(r, g, b));
    }

    final rnd = math.Random(42);
    final confettiColors = [
      img.ColorRgb8(255, 80, 120),
      img.ColorRgb8(255, 215, 0),
      img.ColorRgb8(0, 210, 210),
      img.ColorRgb8(150, 100, 255),
      img.ColorRgb8(120, 220, 80),
    ];
    for (int i = 0; i < 90; i++) {
      final x = rnd.nextInt(800);
      final y = rnd.nextInt(600);
      img.fillCircle(image, x: x, y: y, radius: rnd.nextInt(8) + 4, color: confettiColors[i % confettiColors.length]);
    }

    img.fillRect(image, x1: 250, y1: 380, x2: 550, y2: 480, color: img.ColorRgb8(255, 150, 180));
    for (int x = 250; x <= 550; x += 30) {
      img.fillCircle(image, x: x, y: 385, radius: 15, color: img.ColorRgb8(255, 255, 255));
    }

    img.fillRect(image, x1: 300, y1: 290, x2: 500, y2: 380, color: img.ColorRgb8(110, 220, 230));
    for (int x = 300; x <= 500; x += 25) {
      img.fillCircle(image, x: x, y: 295, radius: 14, color: img.ColorRgb8(255, 255, 255));
    }

    for (int i = 0; i < 3; i++) {
      final cx = 350 + i * 50;
      img.fillRect(image, x1: cx - 6, y1: 220, x2: cx + 6, y2: 290, color: img.ColorRgb8(255, 225, 80));
      img.fillCircle(image, x: cx, y: 205, radius: 10, color: img.ColorRgb8(255, 120, 30));
      img.fillCircle(image, x: cx, y: 205, radius: 5, color: img.ColorRgb8(255, 240, 100));
    }

    return image;
  }
}
