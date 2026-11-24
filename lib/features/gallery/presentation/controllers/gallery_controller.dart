import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photokids_studio/core/di/app_providers.dart';
import 'package:photokids_studio/domain/entities/photo_entity.dart';
import 'package:photokids_studio/domain/repositories/i_photo_repository.dart';

enum GalleryViewMode {
  grid,
  list,
}

enum GallerySortOption {
  dateDesc,
  dateAsc,
  nameAsc,
  nameDesc,
  sizeDesc,
  favoriteFirst,
}

enum GalleryFilterTab {
  all,
  favorites,
  trash,
  album,
}

class GalleryState {
  final List<PhotoEntity> allPhotos;
  final List<PhotoEntity> displayPhotos;
  final bool isLoading;
  final GalleryViewMode viewMode;
  final GallerySortOption sortOption;
  final GalleryFilterTab currentTab;
  final int gridColumns;
  final String searchQuery;
  final String? activeAlbumId;
  final String? errorMessage;

  const GalleryState({
    this.allPhotos = const [],
    this.displayPhotos = const [],
    this.isLoading = false,
    this.viewMode = GalleryViewMode.grid,
    this.sortOption = GallerySortOption.dateDesc,
    this.currentTab = GalleryFilterTab.all,
    this.gridColumns = 3,
    this.searchQuery = '',
    this.activeAlbumId,
    this.errorMessage,
  });

  GalleryState copyWith({
    List<PhotoEntity>? allPhotos,
    List<PhotoEntity>? displayPhotos,
    bool? isLoading,
    GalleryViewMode? viewMode,
    GallerySortOption? sortOption,
    GalleryFilterTab? currentTab,
    int? gridColumns,
    String? searchQuery,
    String? activeAlbumId,
    String? errorMessage,
  }) {
    return GalleryState(
      allPhotos: allPhotos ?? this.allPhotos,
      displayPhotos: displayPhotos ?? this.displayPhotos,
      isLoading: isLoading ?? this.isLoading,
      viewMode: viewMode ?? this.viewMode,
      sortOption: sortOption ?? this.sortOption,
      currentTab: currentTab ?? this.currentTab,
      gridColumns: gridColumns ?? this.gridColumns,
      searchQuery: searchQuery ?? this.searchQuery,
      activeAlbumId: activeAlbumId ?? this.activeAlbumId,
      errorMessage: errorMessage,
    );
  }
}

class GalleryNotifier extends StateNotifier<GalleryState> {
  final IPhotoRepository _repository;

  GalleryNotifier(this._repository) : super(const GalleryState()) {
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    state = state.copyWith(isLoading: true);
    try {
      List<PhotoEntity> photos;
      if (state.currentTab == GalleryFilterTab.trash) {
        photos = await _repository.getTrashPhotos();
      } else if (state.currentTab == GalleryFilterTab.favorites) {
        photos = await _repository.getFavoritePhotos();
      } else if (state.currentTab == GalleryFilterTab.album && state.activeAlbumId != null) {
        photos = await _repository.getPhotosByAlbum(state.activeAlbumId!);
      } else {
        photos = await _repository.getAllPhotos(includeDeleted: false);
      }

      state = state.copyWith(
        allPhotos: photos,
        isLoading: false,
      );
      _applyFilteringAndSorting();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setFilterTab(GalleryFilterTab tab, {String? albumId}) {
    state = state.copyWith(currentTab: tab, activeAlbumId: albumId);
    loadPhotos();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilteringAndSorting();
  }

  void setViewMode(GalleryViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setGridColumns(int cols) {
    if (cols >= 2 && cols <= 6) {
      state = state.copyWith(gridColumns: cols);
    }
  }

  void setSortOption(GallerySortOption sort) {
    state = state.copyWith(sortOption: sort);
    _applyFilteringAndSorting();
  }

  Future<void> toggleFavorite(PhotoEntity photo) async {
    final newFlag = photo.isFavorite ? PhotoFlag.none : PhotoFlag.favorite;
    await _repository.setPhotoFlag(photo.id, newFlag);
    await loadPhotos();
  }

  Future<void> setFlag(String photoId, PhotoFlag flag) async {
    await _repository.setPhotoFlag(photoId, flag);
    await loadPhotos();
  }

  Future<void> moveToTrash(String photoId) async {
    await _repository.moveToTrash(photoId);
    await loadPhotos();
  }

  Future<void> restoreFromTrash(String photoId) async {
    await _repository.restoreFromTrash(photoId);
    await loadPhotos();
  }

  Future<void> deletePermanently(String photoId) async {
    await _repository.deletePermanently(photoId);
    await loadPhotos();
  }

  Future<void> saveNewPhoto(PhotoEntity photo) async {
    await _repository.savePhoto(photo);
    await loadPhotos();
  }

  void _applyFilteringAndSorting() {
    var list = List<PhotoEntity>.from(state.allPhotos);

    // Apply Search Filter
    if (state.searchQuery.trim().isNotEmpty) {
      final q = state.searchQuery.trim().toLowerCase();
      list = list.where((p) {
        final matchName = p.fileName.toLowerCase().contains(q);
        final matchCategory = p.category?.toLowerCase().contains(q) ?? false;
        final matchTags = p.tags.any((t) => t.toLowerCase().contains(q));
        return matchName || matchCategory || matchTags;
      }).toList();
    }

    // Apply Sorting
    switch (state.sortOption) {
      case GallerySortOption.dateDesc:
        list.sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
        break;
      case GallerySortOption.dateAsc:
        list.sort((a, b) => a.dateTaken.compareTo(b.dateTaken));
        break;
      case GallerySortOption.nameAsc:
        list.sort((a, b) => a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));
        break;
      case GallerySortOption.nameDesc:
        list.sort((a, b) => b.fileName.toLowerCase().compareTo(a.fileName.toLowerCase()));
        break;
      case GallerySortOption.sizeDesc:
        list.sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));
        break;
      case GallerySortOption.favoriteFirst:
        list.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return b.dateTaken.compareTo(a.dateTaken);
        });
        break;
    }

    state = state.copyWith(displayPhotos: list);
  }
}

final galleryControllerProvider = StateNotifierProvider<GalleryNotifier, GalleryState>((ref) {
  final repo = ref.watch(photoRepositoryProvider);
  return GalleryNotifier(repo);
});
