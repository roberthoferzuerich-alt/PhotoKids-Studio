import 'dart:io';
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
    final count = await photoRepo.getTotalPhotoCount();
    if (count > 0 || kIsWeb) return;

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final sampleDir = Directory(p.join(docsDir.path, 'sample_photos'));
      if (!await sampleDir.exists()) {
        await sampleDir.create(recursive: true);
      }

      // Create default albums
      final albumUrlaub = AlbumEntity(
        id: 'album_urlaub',
        name: 'Sommerurlaub 🏖️',
        description: 'Tolle Strand- und Sonnentage',
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

      // Generate 4 colorful sample images
      final samples = [
        {'title': 'Sonniger_Strand.jpg', 'color': [255, 235, 59], 'album': 'album_urlaub', 'cat': 'Urlaub 🏖️'},
        {'title': 'Mein_Lieblingshund.jpg', 'color': [255, 112, 67], 'album': 'album_tiere', 'cat': 'Tiere 🐶'},
        {'title': 'Regenbogen_Garten.jpg', 'color': [77, 208, 225], 'album': 'album_urlaub', 'cat': 'Natur 🌸'},
        {'title': 'Geburtstags_Kuchen.jpg', 'color': [240, 98, 146], 'album': null, 'cat': 'Party 🎉'},
      ];

      for (int i = 0; i < samples.length; i++) {
        final info = samples[i];
        final filename = info['title'] as String;
        final color = info['color'] as List<int>;
        final filePath = p.join(sampleDir.path, filename);

        // Generate a 1200x900 image with gradient & shapes
        final sampleImage = img.Image(width: 1200, height: 900);
        img.fill(sampleImage, color: img.ColorRgb8(color[0], color[1], color[2]));
        img.fillCircle(sampleImage, x: 600, y: 450, radius: 250, color: img.ColorRgb8(255, 255, 255));
        img.fillCircle(sampleImage, x: 600, y: 450, radius: 200, color: img.ColorRgb8(color[0] ~/ 2, color[1], color[2] ~/ 2));

        final jpgBytes = img.encodeJpg(sampleImage, quality: 85);
        final file = File(filePath);
        await file.writeAsBytes(jpgBytes);

        final photo = PhotoEntity(
          id: const Uuid().v4(),
          filePath: filePath,
          fileName: filename,
          fileExtension: 'jpg',
          fileSizeBytes: jpgBytes.length,
          width: 1200,
          height: 900,
          dateTaken: DateTime.now().subtract(Duration(days: i * 2, hours: i * 3)),
          dateAdded: DateTime.now(),
          flag: i == 0 ? PhotoFlag.favorite : PhotoFlag.none,
          albumId: info['album'] as String?,
          category: info['cat'] as String?,
          tags: ['fotokids', 'bunt', 'spaß'],
        );

        await photoRepo.savePhoto(photo);
      }
    } catch (e) {
      debugPrint('Sample data seeding error: $e');
    }
  }
}
