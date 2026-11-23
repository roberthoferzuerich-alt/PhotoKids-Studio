import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:denis_phote_world/core/di/app_providers.dart';
import 'package:denis_phote_world/domain/entities/album_entity.dart';
import 'package:denis_phote_world/domain/repositories/i_album_repository.dart';

class AlbumsState {
  final List<AlbumEntity> albums;
  final bool isLoading;
  final String? errorMessage;

  const AlbumsState({
    this.albums = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AlbumsState copyWith({
    List<AlbumEntity>? albums,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AlbumsState(
      albums: albums ?? this.albums,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AlbumsNotifier extends StateNotifier<AlbumsState> {
  final IAlbumRepository _repository;

  AlbumsNotifier(this._repository) : super(const AlbumsState()) {
    loadAlbums();
  }

  Future<void> loadAlbums() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await _repository.getAllAlbums();
      state = state.copyWith(albums: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createAlbum(String name, {String emoji = '📁', String? description}) async {
    final album = AlbumEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
      iconEmoji: emoji,
    );
    await _repository.createAlbum(album);
    await loadAlbums();
  }

  Future<void> deleteAlbum(String id) async {
    await _repository.deleteAlbum(id);
    await loadAlbums();
  }
}

final albumsControllerProvider = StateNotifierProvider<AlbumsNotifier, AlbumsState>((ref) {
  final repo = ref.watch(albumRepositoryProvider);
  return AlbumsNotifier(repo);
});
