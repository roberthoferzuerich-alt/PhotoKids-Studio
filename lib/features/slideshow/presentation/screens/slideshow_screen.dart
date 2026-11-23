import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:denis_phote_world/core/theme/app_colors.dart';
import 'package:denis_phote_world/domain/entities/photo_entity.dart';
import 'package:denis_phote_world/features/gallery/presentation/controllers/gallery_controller.dart';
import 'package:denis_phote_world/features/settings/presentation/controllers/settings_controller.dart';

class SlideshowScreen extends ConsumerStatefulWidget {
  const SlideshowScreen({super.key});

  @override
  ConsumerState<SlideshowScreen> createState() => _SlideshowScreenState();
}

class _SlideshowScreenState extends ConsumerState<SlideshowScreen> {
  int _currentIndex = 0;
  bool _isPlaying = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    final speed = ref.read(settingsControllerProvider).slideshowSpeed;
    _timer = Timer.periodic(Duration(seconds: speed), (timer) {
      if (_isPlaying) {
        _nextSlide();
      }
    });
  }

  void _nextSlide() {
    final photos = ref.read(galleryControllerProvider).displayPhotos;
    if (photos.isNotEmpty) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % photos.length;
      });
    }
  }

  void _prevSlide() {
    final photos = ref.read(galleryControllerProvider).displayPhotos;
    if (photos.isNotEmpty) {
      setState(() {
        _currentIndex = (_currentIndex - 1 + photos.length) % photos.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(galleryControllerProvider).displayPhotos;

    if (photos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diashow')),
        body: const Center(child: Text('Keine Fotos für die Diashow vorhanden.')),
      );
    }

    final currentPhoto = photos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated Transition Image
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation), child: child),
              );
            },
            child: _buildSlideshowImage(currentPhoto),
          ),

          // Top Controls (Close, photo title)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentPhoto.fileName.replaceAll('.jpg', '').replaceAll('.png', '').replaceAll('_', ' '),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${_currentIndex + 1} / ${photos.length}',
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Control Bar with SafeArea
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 32),
                        onPressed: _prevSlide,
                      ),
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                          color: AppColors.pinkPrimary,
                          size: 48,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPlaying = !_isPlaying;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
                        onPressed: _nextSlide,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideshowImage(PhotoEntity photo) {
    if (!kIsWeb) {
      final file = File(photo.filePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          key: ValueKey<String>(photo.id),
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        );
      }
    }
    return Container(
      key: ValueKey<String>(photo.id),
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.image, color: Colors.white38, size: 80),
      ),
    );
  }
}
