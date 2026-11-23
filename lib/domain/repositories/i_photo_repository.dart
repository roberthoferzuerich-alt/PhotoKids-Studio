import 'package:denis_phote_world/domain/entities/photo_entity.dart';

abstract class IPhotoRepository {
  Future<List<PhotoEntity>> getAllPhotos({bool includeDeleted = false});
  Future<PhotoEntity?> getPhotoById(String id);
  Future<List<PhotoEntity>> getPhotosByAlbum(String albumId);
  Future<List<PhotoEntity>> getFavoritePhotos();
  Future<List<PhotoEntity>> getTrashPhotos();
  Future<List<PhotoEntity>> searchPhotos({String? query, List<String>? tags, String? category});
  Future<void> savePhoto(PhotoEntity photo);
  Future<void> updatePhoto(PhotoEntity photo);
  Future<void> moveToTrash(String id);
  Future<void> restoreFromTrash(String id);
  Future<void> deletePermanently(String id);
  Future<void> cleanExpiredTrash(int retentionDays);
  Future<void> setPhotoFlag(String id, PhotoFlag flag);
  Future<void> assignToAlbum(String photoId, String? albumId);
  Future<int> getTotalPhotoCount();
}
