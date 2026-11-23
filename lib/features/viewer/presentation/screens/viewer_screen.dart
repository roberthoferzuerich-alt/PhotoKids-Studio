import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:denis_phote_world/core/theme/app_colors.dart';
import 'package:denis_phote_world/domain/entities/photo_entity.dart';
import 'package:denis_phote_world/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:denis_phote_world/features/settings/presentation/controllers/settings_controller.dart';
import 'package:denis_phote_world/shared/widgets/parental_gate_dialog.dart';

class ViewerScreen extends ConsumerStatefulWidget {
  final PhotoEntity? photo;

  const ViewerScreen({super.key, this.photo});

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  final TransformationController _transformController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _isFullscreen = false;
  int _rotationQuarterTurns = 0;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_transformController.value != Matrix4.identity()) {
      _transformController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      _transformController.value = Matrix4.identity()
        ..translate(-position.dx * 1.5, -position.dy * 1.5)
        ..scale(2.5);
    }
  }

  void _sharePhoto(PhotoEntity photo) async {
    if (!kIsWeb && File(photo.filePath).existsSync()) {
      await Share.shareXFiles([XFile(photo.filePath)], text: 'Schau dir mein Foto aus PhotoKids Studio an!');
    } else {
      await Share.share('Foto: ${photo.fileName}');
    }
  }

  void _confirmDelete(PhotoEntity photo) {
    final settings = ref.read(settingsControllerProvider);

    void executeDelete() async {
      final galleryNotifier = ref.read(galleryControllerProvider.notifier);
      if (photo.isDeleted) {
        await galleryNotifier.deletePermanently(photo.id);
      } else {
        await galleryNotifier.moveToTrash(photo.id);
      }
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              photo.isDeleted
                  ? 'Foto endgültig gelöscht'
                  : 'In den Papierkorb verschoben (30 Tage aufbewahrt)',
            ),
          ),
        );
      }
    }

    if (settings.isKidMode) {
      ParentalGateDialog.show(
        context,
        onAuthenticated: () => _showDeleteDialog(executeDelete),
      );
    } else {
      _showDeleteDialog(executeDelete);
    }
  }

  void _showDeleteDialog(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Foto löschen? 🗑️'),
        content: const Text(
          'Möchtest du dieses Foto in den Papierkorb verschieben? '
          'Dort bleibt es 30 Tage lang aufbewahrt und kann jederzeit wiederhergestellt werden.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Abbrechen')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _showExifDetails(PhotoEntity photo) {
    final dateFormat = DateFormat('dd. MMMM yyyy, HH:mm:ss');
    final sizeMb = (photo.fileSizeBytes / (1024 * 1024)).toStringAsFixed(2);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.pinkSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppColors.pinkPrimary, size: 24),
                ),
                const SizedBox(width: 12),
                const Text('Bildinformationen (EXIF)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(ctx).pop()),
              ],
            ),
            const Divider(height: 24),
            _buildExifRow('📁 Dateiname', photo.fileName),
            _buildExifRow('📐 Auflösung', '${photo.width} × ${photo.height} Pixel'),
            _buildExifRow('💾 Dateigröße', '$sizeMb MB (${photo.fileSizeBytes} Bytes)'),
            _buildExifRow('📅 Datum', dateFormat.format(photo.dateTaken)),
            _buildExifRow('🏷️ Format', photo.fileExtension.toUpperCase()),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildExifRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    if (photo == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Foto nicht gefunden')),
      );
    }

    final galleryNotifier = ref.read(galleryControllerProvider.notifier);
    final cleanName = photo.fileName.replaceAll('.jpg', '').replaceAll('.png', '').replaceAll('_', ' ');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen
          ? null
          : AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              titleSpacing: 0,
              title: Text(
                cleanName,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    photo.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: photo.isFavorite ? AppColors.pinkPrimary : Colors.white,
                  ),
                  tooltip: 'Favorit',
                  onPressed: () => galleryNotifier.toggleFavorite(photo),
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  tooltip: 'Teilen',
                  onPressed: () => _sharePhoto(photo),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  tooltip: 'Mehr Optionen',
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'rotate',
                      child: Row(
                        children: [
                          Icon(Icons.rotate_right_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Um 90° drehen'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'info',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Bilddetails (EXIF)'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          SizedBox(width: 10),
                          Text('Löschen', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (val) {
                    if (val == 'rotate') {
                      setState(() => _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4);
                    } else if (val == 'info') {
                      _showExifDetails(photo);
                    } else if (val == 'delete') {
                      _confirmDelete(photo);
                    }
                  },
                ),
                const SizedBox(width: 4),
              ],
            ),
      body: GestureDetector(
        onTap: () => setState(() => _isFullscreen = !_isFullscreen),
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: _handleDoubleTap,
        child: Center(
          child: RotatedBox(
            quarterTurns: _rotationQuarterTurns,
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.8,
              maxScale: 5.0,
              child: Hero(
                tag: 'photo_${photo.id}',
                child: _buildMainImage(photo),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _isFullscreen
          ? null
          : Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // 1. Bearbeiten Button (Flexible)
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.pinkGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.pinkPrimary.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            label: const Text(
                              'Bearbeiten 🎨',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: () => context.push('/editor', extra: photo),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 2. Web-Größe Button (Flexible)
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.turquoiseLight,
                              side: const BorderSide(color: AppColors.turquoiseSecondary, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            icon: const Icon(Icons.public_rounded, size: 18),
                            label: const Text(
                              'Web-Größe 🌐',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onPressed: () => context.push('/editor', extra: photo),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 3. Diashow Button (Kreisrundes Icon)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.slideshow_rounded, color: Colors.white, size: 24),
                          tooltip: 'Diashow starten',
                          onPressed: () => context.push('/slideshow'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMainImage(PhotoEntity photo) {
    final file = File(photo.filePath);
    if (!kIsWeb && file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.image_rounded, color: Colors.white54, size: 64),
      ),
    );
  }
}
