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
                        color: isSelected ? AppColors.pinkPrimary.withOpacity(0.3) : Colors.transparent,
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.pinkPrimary, foregroundColor: Colors.white),
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

    return Scaffold(
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
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: albumsState.albums.length,
                  itemBuilder: (context, index) {
                    final album = albumsState.albums[index];
                    return _buildAlbumCard(context, ref, album);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.turquoiseSecondary,
        icon: const Icon(Icons.create_new_folder_rounded, size: 28),
        label: const Text('Neues Album', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showCreateAlbumDialog(context, ref),
      ),
    );
  }

  Widget _buildAlbumCard(BuildContext context, WidgetRef ref, AlbumEntity album) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          ref.read(galleryControllerProvider.notifier).setFilterTab(GalleryFilterTab.album, albumId: album.id);
          context.pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.turquoiseLight.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(album.iconEmoji, style: const TextStyle(fontSize: 38)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                album.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${album.photoCount} Fotos',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
