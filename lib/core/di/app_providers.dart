import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:denis_phote_world/data/datasources/album_local_datasource.dart';
import 'package:denis_phote_world/data/datasources/photo_local_datasource.dart';
import 'package:denis_phote_world/data/datasources/preferences_datasource.dart';
import 'package:denis_phote_world/data/repositories/album_repository_impl.dart';
import 'package:denis_phote_world/data/repositories/photo_repository_impl.dart';
import 'package:denis_phote_world/data/repositories/settings_repository_impl.dart';
import 'package:denis_phote_world/domain/repositories/i_album_repository.dart';
import 'package:denis_phote_world/domain/repositories/i_photo_repository.dart';
import 'package:denis_phote_world/domain/repositories/i_settings_repository.dart';
import 'package:denis_phote_world/services/cloud/cloud_sync_service.dart';
import 'package:denis_phote_world/services/ai/ai_vision_service.dart';
import 'package:denis_phote_world/services/storage/thumbnail_cache_service.dart';

// Datasources
final photoDatasourceProvider = Provider<PhotoLocalDatasource>((ref) {
  return PhotoLocalDatasource();
});

final albumDatasourceProvider = Provider<AlbumLocalDatasource>((ref) {
  return AlbumLocalDatasource();
});

final preferencesDatasourceProvider = Provider<PreferencesDatasource>((ref) {
  return PreferencesDatasource();
});

// Repositories
final photoRepositoryProvider = Provider<IPhotoRepository>((ref) {
  final ds = ref.watch(photoDatasourceProvider);
  return PhotoRepositoryImpl(ds);
});

final albumRepositoryProvider = Provider<IAlbumRepository>((ref) {
  final ds = ref.watch(albumDatasourceProvider);
  return AlbumRepositoryImpl(ds);
});

final settingsRepositoryProvider = Provider<ISettingsRepository>((ref) {
  final ds = ref.watch(preferencesDatasourceProvider);
  return SettingsRepositoryImpl(ds);
});

// Services
final thumbnailCacheServiceProvider = Provider<ThumbnailCacheService>((ref) {
  return ThumbnailCacheService();
});

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService();
});

final aiVisionServiceProvider = Provider<IAiVisionService>((ref) {
  return AiVisionServiceImpl();
});
