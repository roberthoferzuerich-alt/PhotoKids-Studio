import 'package:photokids_studio/data/datasources/photo_local_datasource.dart';
import 'package:photokids_studio/data/models/photo_model.dart';
import 'package:photokids_studio/domain/entities/photo_entity.dart';
import 'package:photokids_studio/domain/repositories/i_photo_repository.dart';

class PhotoRepositoryImpl implements IPhotoRepository {
  final PhotoLocalDatasource _datasource;

  PhotoRepositoryImpl(this._datasource);

  @override
  Future<List<PhotoEntity>> getAllPhotos({bool includeDeleted = false}) async {
    final models = await _datasource.getAllPhotos(includeDeleted: includeDeleted);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<PhotoEntity?> getPhotoById(String id) async {
    final model = await _datasource.getPhotoById(id);
    return model?.toEntity();
  }

  @override
  Future<List<PhotoEntity>> getPhotosByAlbum(String albumId) async {
    final models = await _datasource.getPhotosByAlbum(albumId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<PhotoEntity>> getFavoritePhotos() async {
    final models = await _datasource.getFavoritePhotos();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<PhotoEntity>> getTrashPhotos() async {
    final models = await _datasource.getTrashPhotos();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<PhotoEntity>> searchPhotos({String? query, List<String>? tags, String? category}) async {
    final models = await _datasource.searchPhotos(query: query, tags: tags, category: category);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> savePhoto(PhotoEntity photo) async {
    await _datasource.insertPhoto(PhotoModel.fromEntity(photo));
  }

  @override
  Future<void> updatePhoto(PhotoEntity photo) async {
    await _datasource.updatePhoto(PhotoModel.fromEntity(photo));
  }

  @override
  Future<void> moveToTrash(String id) async {
    await _datasource.moveToTrash(id);
  }

  @override
  Future<void> restoreFromTrash(String id) async {
    await _datasource.restoreFromTrash(id);
  }

  @override
  Future<void> deletePermanently(String id) async {
    await _datasource.deletePermanently(id);
  }

  @override
  Future<void> cleanExpiredTrash(int retentionDays) async {
    await _datasource.cleanExpiredTrash(retentionDays);
  }

  @override
  Future<void> setPhotoFlag(String id, PhotoFlag flag) async {
    await _datasource.setPhotoFlag(id, flag);
  }

  @override
  Future<void> assignToAlbum(String photoId, String? albumId) async {
    await _datasource.assignToAlbum(photoId, albumId);
  }

  @override
  Future<int> getTotalPhotoCount() async {
    return await _datasource.getTotalPhotoCount();
  }
}
