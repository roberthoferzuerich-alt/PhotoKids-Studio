import 'package:denis_phote_world/domain/entities/album_entity.dart';

abstract class IAlbumRepository {
  Future<List<AlbumEntity>> getAllAlbums();
  Future<AlbumEntity?> getAlbumById(String id);
  Future<void> createAlbum(AlbumEntity album);
  Future<void> updateAlbum(AlbumEntity album);
  Future<void> deleteAlbum(String id);
  Future<void> refreshAlbumPhotoCounts();
}
