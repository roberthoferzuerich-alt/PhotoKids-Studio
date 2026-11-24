import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photokids_studio/data/datasources/album_local_datasource.dart';
import 'package:photokids_studio/data/datasources/photo_local_datasource.dart';
import 'package:photokids_studio/data/datasources/preferences_datasource.dart';
import 'package:photokids_studio/data/repositories/album_repository_impl.dart';
import 'package:photokids_studio/data/repositories/photo_repository_impl.dart';
import 'package:photokids_studio/data/repositories/settings_repository_impl.dart';
import 'package:photokids_studio/domain/repositories/i_album_repository.dart';
import 'package:photokids_studio/domain/repositories/i_photo_repository.dart';
import 'package:photokids_studio/domain/repositories/i_settings_repository.dart';
import 'package:photokids_studio/services/cloud/cloud_sync_service.dart';
import 'package:photokids_studio/services/ai/ai_vision_service.dart';
import 'package:photokids_studio/services/storage/thumbnail_cache_service.dart';

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
