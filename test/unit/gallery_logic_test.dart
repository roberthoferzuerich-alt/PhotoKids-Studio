import 'package:flutter_test/flutter_test.dart';
import 'package:photokids_studio/domain/entities/photo_entity.dart';
import 'package:photokids_studio/domain/repositories/i_photo_repository.dart';
import 'package:photokids_studio/features/gallery/presentation/controllers/gallery_controller.dart';

class MockPhotoRepository implements IPhotoRepository {
  final List<PhotoEntity> photos;

  MockPhotoRepository(this.photos);

  @override
  Future<List<PhotoEntity>> getAllPhotos({bool includeDeleted = false}) async => photos;

  @override
  Future<List<PhotoEntity>> getFavoritePhotos() async =>
      photos.where((p) => p.isFavorite).toList();

  @override
  Future<List<PhotoEntity>> getTrashPhotos() async =>
      photos.where((p) => p.isDeleted).toList();

  @override
  Future<List<PhotoEntity>> getPhotosByAlbum(String albumId) async =>
      photos.where((p) => p.albumId == albumId).toList();

  @override
  Future<PhotoEntity?> getPhotoById(String id) async =>
      photos.firstWhere((p) => p.id == id);

  @override
  Future<List<PhotoEntity>> searchPhotos({String? query, List<String>? tags, String? category}) async => photos;

  @override
  Future<void> savePhoto(PhotoEntity photo) async => photos.add(photo);

  @override
  Future<void> updatePhoto(PhotoEntity photo) async {}

  @override
  Future<void> moveToTrash(String id) async {}

  @override
  Future<void> restoreFromTrash(String id) async {}

  @override
  Future<void> deletePermanently(String id) async => photos.removeWhere((p) => p.id == id);

  @override
  Future<void> cleanExpiredTrash(int retentionDays) async {}

  @override
  Future<void> setPhotoFlag(String id, PhotoFlag flag) async {}

  @override
  Future<void> assignToAlbum(String photoId, String? albumId) async {}

  @override
  Future<int> getTotalPhotoCount() async => photos.length;
}

void main() {
  group('Gallery Filtering & Sorting Unit Tests', () {
    late MockPhotoRepository repo;
    late List<PhotoEntity> samplePhotos;

    setUp(() {
      final now = DateTime.now();
      samplePhotos = [
        PhotoEntity(
          id: '1',
          filePath: '/1.jpg',
          fileName: 'Katze_Luna.jpg',
          fileExtension: 'jpg',
          fileSizeBytes: 2000,
          width: 800,
          height: 600,
          dateTaken: now.subtract(const Duration(days: 2)),
          dateAdded: now,
          tags: const ['haustier', 'tier'],
        ),
        PhotoEntity(
          id: '2',
          filePath: '/2.jpg',
          fileName: 'Strand_Urlaub.jpg',
          fileExtension: 'jpg',
          fileSizeBytes: 5000,
          width: 1920,
          height: 1080,
          dateTaken: now.subtract(const Duration(days: 1)),
          dateAdded: now,
          flag: PhotoFlag.favorite,
          tags: const ['urlaub', 'meer'],
        ),
        PhotoEntity(
          id: '3',
          filePath: '/3.jpg',
          fileName: 'Apfelbaum.jpg',
          fileExtension: 'jpg',
          fileSizeBytes: 1000,
          width: 600,
          height: 600,
          dateTaken: now,
          dateAdded: now,
          tags: const ['natur', 'garten'],
        ),
      ];
      repo = MockPhotoRepository(samplePhotos);
    });

    test('Searches by filename or tag correctly', () async {
      final notifier = GalleryNotifier(repo);
      await notifier.loadPhotos();

      notifier.setSearchQuery('Katze');
      expect(notifier.state.displayPhotos.length, equals(1));
      expect(notifier.state.displayPhotos.first.fileName, equals('Katze_Luna.jpg'));

      notifier.setSearchQuery('meer');
      expect(notifier.state.displayPhotos.length, equals(1));
      expect(notifier.state.displayPhotos.first.fileName, equals('Strand_Urlaub.jpg'));
    });

    test('Sorts by name ascending and descending', () async {
      final notifier = GalleryNotifier(repo);
      await notifier.loadPhotos();

      notifier.setSortOption(GallerySortOption.nameAsc);
      expect(notifier.state.displayPhotos.first.fileName, equals('Apfelbaum.jpg'));

      notifier.setSortOption(GallerySortOption.nameDesc);
      expect(notifier.state.displayPhotos.first.fileName, equals('Strand_Urlaub.jpg'));
    });

    test('Sorts favorites first', () async {
      final notifier = GalleryNotifier(repo);
      await notifier.loadPhotos();

      notifier.setSortOption(GallerySortOption.favoriteFirst);
      expect(notifier.state.displayPhotos.first.fileName, equals('Strand_Urlaub.jpg'));
      expect(notifier.state.displayPhotos.first.isFavorite, isTrue);
    });
  });
}
