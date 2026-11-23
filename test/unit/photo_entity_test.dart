import 'package:flutter_test/flutter_test.dart';
import 'package:denis_phote_world/domain/entities/photo_entity.dart';

void main() {
  group('PhotoEntity Unit Tests', () {
    test('Calculates remaining trash retention days accurately (30 days total)', () {
      final now = DateTime.now();
      final photo = PhotoEntity(
        id: 'p1',
        filePath: '/test/photo.jpg',
        fileName: 'photo.jpg',
        fileExtension: 'jpg',
        fileSizeBytes: 1024,
        width: 1920,
        height: 1080,
        dateTaken: now,
        dateAdded: now,
        isDeleted: true,
        deletedAt: now.subtract(const Duration(days: 10)),
      );

      // 30 days total - 10 days elapsed = 20 remaining
      expect(photo.remainingTrashDays, inInclusiveRange(19, 20));
    });

    test('Identifies flags correctly', () {
      final photoFav = PhotoEntity(
        id: 'p2',
        filePath: '/test/fav.jpg',
        fileName: 'fav.jpg',
        fileExtension: 'jpg',
        fileSizeBytes: 2048,
        width: 800,
        height: 600,
        dateTaken: DateTime.now(),
        dateAdded: DateTime.now(),
        flag: PhotoFlag.favorite,
      );

      expect(photoFav.isFavorite, isTrue);
      expect(photoFav.isImportant, isFalse);
      expect(photoFav.isEditLater, isFalse);
    });

    test('CopyWith updates properties immutably', () {
      final initial = PhotoEntity(
        id: 'p3',
        filePath: '/path/test.png',
        fileName: 'test.png',
        fileExtension: 'png',
        fileSizeBytes: 500,
        width: 400,
        height: 300,
        dateTaken: DateTime.now(),
        dateAdded: DateTime.now(),
      );

      final updated = initial.copyWith(fileName: 'renamed.png', flag: PhotoFlag.important);

      expect(updated.id, equals('p3'));
      expect(updated.fileName, equals('renamed.png'));
      expect(updated.flag, equals(PhotoFlag.important));
      expect(initial.fileName, equals('test.png'));
    });
  });
}
