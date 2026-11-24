import 'package:photokids_studio/data/datasources/album_local_datasource.dart';
import 'package:photokids_studio/data/models/album_model.dart';
import 'package:photokids_studio/domain/entities/album_entity.dart';
import 'package:photokids_studio/domain/repositories/i_album_repository.dart';

class AlbumRepositoryImpl implements IAlbumRepository {
  final AlbumLocalDatasource _datasource;

  AlbumRepositoryImpl(this._datasource);

  @override
  Future<List<AlbumEntity>> getAllAlbums() async {
    final models = await _datasource.getAllAlbums();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AlbumEntity?> getAlbumById(String id) async {
    final model = await _datasource.getAlbumById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createAlbum(AlbumEntity album) async {
    await _datasource.insertAlbum(AlbumModel.fromEntity(album));
  }

  @override
  Future<void> updateAlbum(AlbumEntity album) async {
    await _datasource.updateAlbum(AlbumModel.fromEntity(album));
  }

  @override
  Future<void> deleteAlbum(String id) async {
    await _datasource.deleteAlbum(id);
  }

  @override
  Future<void> refreshAlbumPhotoCounts() async {
    // Counts are dynamically computed in getAllAlbums
  }
}
