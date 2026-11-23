import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:denis_phote_world/core/theme/app_colors.dart';
import 'package:denis_phote_world/domain/entities/album_entity.dart';
import 'package:denis_phote_world/features/albums/presentation/controllers/albums_controller.dart';
import 'package:denis_phote_world/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:denis_phote_world/shared/widgets/kid_button.dart';

class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  void _showCreateAlbumDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedEmoji = '📁';
    final emojis = ['📁', '🏖️', '🎂', '🐶', '🦄', '🌈', '🎨', '🚀', '⚽', '🎒'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Neues Album erstellen 📁', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Name des Albums (z.B. Urlaub 🏖️)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Wähle ein Icon:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: emojis.map((emoji) {
                  final isSelected = selectedEmoji == emoji;
                  return GestureDetector(
                    onTap: () => setDialogState(() => selectedEmoji = emoji),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.pinkPrimary.withValues(alpha: 0.3) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: AppColors.pinkPrimary, width: 2) : null,
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pinkPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  ref.read(albumsControllerProvider.notifier).createAlbum(name, emoji: selectedEmoji);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Erstellen'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsState = ref.watch(albumsControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: const Text('Meine Foto-Alben 📚'),
      ),
      body: albumsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : albumsState.albums.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📁', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 16),
                      const Text('Noch keine Alben da!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Erstelle dein erstes Album für Urlaube, Tiere oder Geburtstagspartys!'),
                      const SizedBox(height: 20),
                      KidButton(
                        label: 'Album erstellen',
                        icon: const Icon(Icons.add),
                        onPressed: () => _showCreateAlbumDialog(context, ref),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 85),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: albumsState.albums.length,
                  itemBuilder: (context, index) {
                    final album = albumsState.albums[index];
                    return _buildAlbumCard(context, ref, album, isDark);
                  },
                ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.turquoiseGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.turquoiseSecondary.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.create_new_folder_rounded, size: 24),
          label: const Text('Neues Album', style: TextStyle(fontWeight: FontWeight.w800)),
          onPressed: () => _showCreateAlbumDialog(context, ref),
        ),
      ),
    );
  }

  Widget _buildAlbumCard(BuildContext context, WidgetRef ref, AlbumEntity album, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF282035) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            ref.read(galleryControllerProvider.notifier).setFilterTab(GalleryFilterTab.album, albumId: album.id);
            context.go('/');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.turquoiseSoft,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.turquoiseSecondary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(album.iconEmoji, style: const TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  album.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.turquoiseSecondary.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${album.photoCount} Fotos',
                    style: TextStyle(
                      color: isDark ? AppColors.turquoiseLight : AppColors.turquoiseDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
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
}
