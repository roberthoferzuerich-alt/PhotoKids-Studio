import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:denis_phote_world/core/constants/app_constants.dart';
import 'package:denis_phote_world/core/theme/app_colors.dart';
import 'package:denis_phote_world/domain/entities/photo_entity.dart';
import 'package:denis_phote_world/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:denis_phote_world/features/settings/presentation/controllers/settings_controller.dart';
import 'package:denis_phote_world/shared/widgets/kid_button.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickAndImportImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedExtensions,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final galleryNotifier = ref.read(galleryControllerProvider.notifier);
        for (final file in result.files) {
          if (file.path != null) {
            final f = File(file.path!);
            final bytes = await f.length();
            final ext = p.extension(file.path!).replaceAll('.', '').toLowerCase();

            final photo = PhotoEntity(
              id: const Uuid().v4(),
              filePath: file.path!,
              fileName: file.name,
              fileExtension: ext,
              fileSizeBytes: bytes,
              width: 1920,
              height: 1080,
              dateTaken: DateTime.now(),
              dateAdded: DateTime.now(),
              category: 'Importiert 📷',
              tags: ['kamera', 'spaß'],
            );
            await galleryNotifier.saveNewPhoto(photo);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Importieren: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final galleryState = ref.watch(galleryControllerProvider);
    final galleryNotifier = ref.read(galleryControllerProvider.notifier);
    final settingsState = ref.watch(settingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Fotos, Tags, Kategorien suchen...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                      });
                      galleryNotifier.setSearchQuery('');
                    },
                  ),
                ),
                onChanged: (val) => galleryNotifier.setSearchQuery(val),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📸 PhotoKids Studio'),
                  const SizedBox(width: 8),
                  if (settingsState.isKidMode)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.yellowAccent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '👧 Kinder-Modus',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                ],
              ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Suche',
              onPressed: () => setState(() => _isSearching = true),
            ),
          // View Mode Switcher
          IconButton(
            icon: Icon(
              galleryState.viewMode == GalleryViewMode.grid
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
            ),
            tooltip: 'Ansicht wechseln',
            onPressed: () {
              galleryNotifier.setViewMode(
                galleryState.viewMode == GalleryViewMode.grid
                    ? GalleryViewMode.list
                    : GalleryViewMode.grid,
              );
            },
          ),
          // Slideshow
          IconButton(
            icon: const Icon(Icons.play_circle_filled_rounded),
            color: AppColors.purpleAccent,
            tooltip: 'Diashow starten',
            onPressed: () => context.push('/slideshow'),
          ),
          // Albums
          IconButton(
            icon: const Icon(Icons.photo_library_rounded),
            tooltip: 'Alben',
            onPressed: () => context.push('/albums'),
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Einstellungen',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs & Sort Row
          _buildFilterAndSortBar(galleryState, galleryNotifier),

          // Zoom / Column Control (Grid Mode only)
          if (galleryState.viewMode == GalleryViewMode.grid)
            _buildGridColumnSlider(galleryState, galleryNotifier),

          // Photos Content
          Expanded(
            child: galleryState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : galleryState.displayPhotos.isEmpty
                    ? _buildEmptyState()
                    : galleryState.viewMode == GalleryViewMode.grid
                        ? _buildGridView(galleryState, galleryNotifier)
                        : _buildListView(galleryState, galleryNotifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndImportImages,
        backgroundColor: AppColors.pinkPrimary,
        icon: const Icon(Icons.add_photo_alternate_rounded, size: 28),
        label: const Text(
          'Fotos hinzufügen',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterAndSortBar(GalleryState state, GalleryNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Alle Fotos 🌟',
              isSelected: state.currentTab == GalleryFilterTab.all,
              onTap: () => notifier.setFilterTab(GalleryFilterTab.all),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Favoriten ⭐',
              isSelected: state.currentTab == GalleryFilterTab.favorites,
              onTap: () => notifier.setFilterTab(GalleryFilterTab.favorites),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Papierkorb 🗑️',
              isSelected: state.currentTab == GalleryFilterTab.trash,
              onTap: () => notifier.setFilterTab(GalleryFilterTab.trash),
            ),
            const SizedBox(width: 16),
            // Sort Dropdown Menu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.pinkLight.withOpacity(0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<GallerySortOption>(
                  value: state.sortOption,
                  icon: const Icon(Icons.sort_rounded, color: AppColors.pinkPrimary),
                  borderRadius: BorderRadius.circular(20),
                  items: const [
                    DropdownMenuItem(
                      value: GallerySortOption.dateDesc,
                      child: Text('📅 Datum (Neueste zuerst)'),
                    ),
                    DropdownMenuItem(
                      value: GallerySortOption.dateAsc,
                      child: Text('📅 Datum (Älteste zuerst)'),
                    ),
                    DropdownMenuItem(
                      value: GallerySortOption.nameAsc,
                      child: Text('🔤 Name (A - Z)'),
                    ),
                    DropdownMenuItem(
                      value: GallerySortOption.nameDesc,
                      child: Text('🔤 Name (Z - A)'),
                    ),
                    DropdownMenuItem(
                      value: GallerySortOption.sizeDesc,
                      child: Text('💾 Größe'),
                    ),
                    DropdownMenuItem(
                      value: GallerySortOption.favoriteFirst,
                      child: Text('⭐ Favoriten zuerst'),
                    ),
                  ],
                  onChanged: (newSort) {
                    if (newSort != null) notifier.setSortOption(newSort);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : null,
        ),
      ),
      selectedColor: AppColors.pinkPrimary,
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => onTap(),
    );
  }

  Widget _buildGridColumnSlider(GalleryState state, GalleryNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Icon(Icons.photo_size_select_small_rounded, color: AppColors.pinkPrimary, size: 20),
          Expanded(
            child: Slider(
              value: state.gridColumns.toDouble(),
              min: 2,
              max: 6,
              divisions: 4,
              activeColor: AppColors.pinkPrimary,
              inactiveColor: AppColors.pinkLight.withOpacity(0.3),
              label: '${state.gridColumns} Spalten',
              onChanged: (val) => notifier.setGridColumns(val.toInt()),
            ),
          ),
          const Icon(Icons.photo_size_select_large_rounded, color: AppColors.pinkPrimary, size: 24),
        ],
      ),
    );
  }

  Widget _buildGridView(GalleryState state, GalleryNotifier notifier) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: state.gridColumns,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: state.displayPhotos.length,
      itemBuilder: (context, index) {
        final photo = state.displayPhotos[index];
        return _buildGridCard(photo, notifier);
      },
    );
  }

  Widget _buildGridCard(PhotoEntity photo, GalleryNotifier notifier) {
    return GestureDetector(
      onTap: () => context.push('/viewer', extra: photo),
      child: Hero(
        tag: 'photo_${photo.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPhotoThumbnail(photo),
              // Top Right Action: Favorite or Trash countdown
              Positioned(
                top: 6,
                right: 6,
                child: photo.isDeleted
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${photo.remainingTrashDays}d',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : IconButton(
                        icon: Icon(
                          photo.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: photo.isFavorite ? Colors.redAccent : Colors.white70,
                          shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
                        ),
                        onPressed: () => notifier.toggleFavorite(photo),
                      ),
              ),
              // Bottom gradient with filename
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Text(
                    photo.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(GalleryState state, GalleryNotifier notifier) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: state.displayPhotos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final photo = state.displayPhotos[index];
        final sizeMb = (photo.fileSizeBytes / (1024 * 1024)).toStringAsFixed(2);

        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(8),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 60,
                height: 60,
                child: _buildPhotoThumbnail(photo),
              ),
            ),
            title: Text(
              photo.fileName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('📅 ${dateFormat.format(photo.dateTaken)}'),
                Text('💾 $sizeMb MB  •  ${photo.width}x${photo.height}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!photo.isDeleted)
                  IconButton(
                    icon: Icon(
                      photo.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: photo.isFavorite ? Colors.redAccent : Colors.grey,
                    ),
                    onPressed: () => notifier.toggleFavorite(photo),
                  ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ],
            ),
            onTap: () => context.push('/viewer', extra: photo),
          ),
        );
      },
    );
  }

  Widget _buildPhotoThumbnail(PhotoEntity photo) {
    final file = File(photo.filePath);
    if (!kIsWeb && file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.turquoiseLight.withOpacity(0.3),
      child: const Center(
        child: Icon(Icons.image_rounded, color: AppColors.turquoiseDark, size: 36),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.pinkLight.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('📸', style: TextStyle(fontSize: 60)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Noch keine Fotos hier!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Füge deine ersten tollen Schnappschüsse hinzu und bearbeite sie mit lustigen Stickern!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              KidButton(
                label: 'Fotos importieren',
                icon: const Icon(Icons.add_photo_alternate_rounded),
                onPressed: _pickAndImportImages,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
