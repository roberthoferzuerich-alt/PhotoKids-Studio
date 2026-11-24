import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:photokids_studio/core/constants/app_constants.dart';
import 'package:photokids_studio/core/theme/app_colors.dart';
import 'package:photokids_studio/domain/entities/photo_entity.dart';
import 'package:photokids_studio/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:photokids_studio/features/settings/presentation/controllers/settings_controller.dart';
import 'package:photokids_studio/shared/widgets/install_app_dialog.dart';
import 'package:photokids_studio/shared/widgets/kid_button.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        titleSpacing: 16,
        title: _isSearching
            ? Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C243B) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Fotos, Tags suchen...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
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
                ),
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.pinkGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pinkPrimary.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text('📸', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'PhotoKids',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (settingsState.isKidMode)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.yellowLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.yellowDark.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('👧', style: TextStyle(fontSize: 11)),
                          SizedBox(width: 3),
                          Text(
                            'Kids',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6B4E00),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.install_mobile_rounded, color: AppColors.turquoiseSecondary),
            tooltip: 'App aufs Handy laden 📲 (Android / Apple)',
            onPressed: () => InstallAppDialog.show(context),
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Suche',
              onPressed: () => setState(() => _isSearching = true),
            ),
          // View Options & Grid Zoom Popup
          PopupMenuButton<String>(
            icon: Icon(
              galleryState.viewMode == GalleryViewMode.grid
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
              color: AppColors.pinkPrimary,
            ),
            tooltip: 'Ansicht & Spalten',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'toggle_mode',
                child: Row(
                  children: [
                    Icon(
                      galleryState.viewMode == GalleryViewMode.grid
                          ? Icons.view_list_rounded
                          : Icons.grid_view_rounded,
                      color: AppColors.pinkPrimary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      galleryState.viewMode == GalleryViewMode.grid
                          ? 'Listenansicht'
                          : 'Rasteransicht',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text('Spaltenanzahl:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              PopupMenuItem(
                value: 'cols_2',
                child: Text('2 Spalten (Groß) ${galleryState.gridColumns == 2 ? '✓' : ''}'),
              ),
              PopupMenuItem(
                value: 'cols_3',
                child: Text('3 Spalten (Standard) ${galleryState.gridColumns == 3 ? '✓' : ''}'),
              ),
              PopupMenuItem(
                value: 'cols_4',
                child: Text('4 Spalten (Kompakt) ${galleryState.gridColumns == 4 ? '✓' : ''}'),
              ),
            ],
            onSelected: (val) {
              if (val == 'toggle_mode') {
                galleryNotifier.setViewMode(
                  galleryState.viewMode == GalleryViewMode.grid
                      ? GalleryViewMode.list
                      : GalleryViewMode.grid,
                );
              } else if (val == 'cols_2') {
                galleryNotifier.setGridColumns(2);
              } else if (val == 'cols_3') {
                galleryNotifier.setGridColumns(3);
              } else if (val == 'cols_4') {
                galleryNotifier.setGridColumns(4);
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs Bar
          _buildFilterBar(galleryState, galleryNotifier, isDark),

          // Photos Content
          Expanded(
            child: galleryState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : galleryState.displayPhotos.isEmpty
                    ? _buildEmptyState()
                    : galleryState.viewMode == GalleryViewMode.grid
                        ? _buildGridView(galleryState, galleryNotifier, isDark)
                        : _buildListView(galleryState, galleryNotifier, isDark),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.pinkGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.pinkPrimary.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          onPressed: _pickAndImportImages,
          icon: const Icon(Icons.add_photo_alternate_rounded, size: 24),
          label: const Text(
            'Fotos hinzufügen',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(GalleryState state, GalleryNotifier notifier, bool isDark) {
    final allCount = state.allPhotos.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip(
                    label: 'Alle 🌟',
                    badge: '$allCount',
                    isSelected: state.currentTab == GalleryFilterTab.all,
                    onTap: () => notifier.setFilterTab(GalleryFilterTab.all),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildTabChip(
                    label: 'Favoriten ⭐',
                    isSelected: state.currentTab == GalleryFilterTab.favorites,
                    onTap: () => notifier.setFilterTab(GalleryFilterTab.favorites),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildTabChip(
                    label: 'Papierkorb 🗑️',
                    isSelected: state.currentTab == GalleryFilterTab.trash,
                    onTap: () => notifier.setFilterTab(GalleryFilterTab.trash),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Sort Menu Icon Button
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2B2338) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PopupMenuButton<GallerySortOption>(
              icon: const Icon(Icons.sort_rounded, size: 20, color: AppColors.pinkPrimary),
              tooltip: 'Sortierung',
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              initialValue: state.sortOption,
              itemBuilder: (ctx) => const [
                PopupMenuItem(
                  value: GallerySortOption.dateDesc,
                  child: Text('📅 Datum (Neueste zuerst)'),
                ),
                PopupMenuItem(
                  value: GallerySortOption.dateAsc,
                  child: Text('📅 Datum (Älteste zuerst)'),
                ),
                PopupMenuItem(
                  value: GallerySortOption.nameAsc,
                  child: Text('🔤 Name (A - Z)'),
                ),
                PopupMenuItem(
                  value: GallerySortOption.nameDesc,
                  child: Text('🔤 Name (Z - A)'),
                ),
                PopupMenuItem(
                  value: GallerySortOption.sizeDesc,
                  child: Text('💾 Dateigröße'),
                ),
                PopupMenuItem(
                  value: GallerySortOption.favoriteFirst,
                  child: Text('⭐ Favoriten zuerst'),
                ),
              ],
              onSelected: (sort) => notifier.setSortOption(sort),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip({
    required String label,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.pinkGradient : null,
          color: isSelected ? null : (isDark ? const Color(0xFF2A2337) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.pinkPrimary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF423B50)),
              ),
            ),
            if (badge != null && !isSelected) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.pinkSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.pinkDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(GalleryState state, GalleryNotifier notifier, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 85),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: state.gridColumns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: state.displayPhotos.length,
      itemBuilder: (context, index) {
        final photo = state.displayPhotos[index];
        return _buildGridCard(photo, notifier, isDark);
      },
    );
  }

  Widget _buildGridCard(PhotoEntity photo, GalleryNotifier notifier, bool isDark) {
    final cleanName = photo.fileName
        .replaceAll('.jpg', '')
        .replaceAll('.png', '')
        .replaceAll('_', ' ');

    return GestureDetector(
      onTap: () => context.push('/viewer', extra: photo),
      child: Hero(
        tag: 'photo_${photo.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: isDark ? const Color(0xFF282035) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildPhotoThumbnail(photo),

                // Top Right: Floating Favorite or Trash Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: photo.isDeleted
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Text(
                            '${photo.remainingTrashDays}d',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      : Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              photo.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: photo.isFavorite
                                  ? AppColors.pinkPrimary
                                  : const Color(0xFF756F86),
                              size: 20,
                            ),
                            onPressed: () => notifier.toggleFavorite(photo),
                          ),
                        ),
                ),

                // Bottom: Clean Floating Title Pill
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      cleanName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(GalleryState state, GalleryNotifier notifier, bool isDark) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 85),
      itemCount: state.displayPhotos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final photo = state.displayPhotos[index];
        final sizeMb = (photo.fileSizeBytes / (1024 * 1024)).toStringAsFixed(2);
        final cleanName = photo.fileName
            .replaceAll('.jpg', '')
            .replaceAll('.png', '')
            .replaceAll('_', ' ');

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF282035) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 60,
                height: 60,
                child: _buildPhotoThumbnail(photo),
              ),
            ),
            title: Text(
              cleanName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text('📅 ${dateFormat.format(photo.dateTaken)}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 8),
                  Text('💾 $sizeMb MB', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!photo.isDeleted)
                  IconButton(
                    icon: Icon(
                      photo.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: photo.isFavorite ? AppColors.pinkPrimary : Colors.grey,
                    ),
                    onPressed: () => notifier.toggleFavorite(photo),
                  ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
            onTap: () => context.push('/viewer', extra: photo),
          ),
        );
      },
    );
  }

  Widget _buildPhotoThumbnail(PhotoEntity photo) {
    if (!kIsWeb) {
      final file = File(photo.filePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.turquoiseGradient,
      ),
      child: const Center(
        child: Icon(Icons.image_rounded, color: Colors.white70, size: 36),
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
                  gradient: AppColors.pinkGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pinkPrimary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('📸', style: TextStyle(fontSize: 56)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Noch keine Fotos hier!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Füge deine ersten tollen Schnappschüsse hinzu und verziere sie mit lustigen Stickern!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              KidButton(
                label: 'Fotos hinzufügen 🎨',
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
