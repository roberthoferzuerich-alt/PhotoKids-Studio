import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:photokids_studio/services/image/image_processing_service.dart';

/// Memory and Disk thumbnail cache to ensure smooth 60fps scrolling
/// with 10.000+ pictures in the gallery.
class ThumbnailCacheService {
  static final ThumbnailCacheService _instance = ThumbnailCacheService._internal();
  factory ThumbnailCacheService() => _instance;
  ThumbnailCacheService._internal();

  // In-memory LRU Cache (max 200 items in memory)
  final LinkedHashMap<String, Uint8List> _memoryCache = LinkedHashMap();
  static const int _maxMemoryEntries = 200;

  Future<Uint8List?> getThumbnail(String photoId, String originalFilePath) async {
    // 1. Check RAM Cache
    if (_memoryCache.containsKey(photoId)) {
      final cached = _memoryCache.remove(photoId)!;
      _memoryCache[photoId] = cached; // re-insert at end (most recently used)
      return cached;
    }

    if (kIsWeb) {
      return null;
    }

    // 2. Check Disk Cache
    try {
      final cacheDir = await _getCacheDirectory();
      final thumbFile = File(p.join(cacheDir.path, '${photoId}_thumb.jpg'));

      if (await thumbFile.exists()) {
        final bytes = await thumbFile.readAsBytes();
        _addToMemory(photoId, bytes);
        return bytes;
      }

      // 3. Generate thumbnail if original file exists
      final origFile = File(originalFilePath);
      if (await origFile.exists()) {
        final origBytes = await origFile.readAsBytes();
        final thumbBytes = await ImageProcessingService.generateThumbnail(origBytes);

        // Save to disk
        await thumbFile.writeAsBytes(thumbBytes);
        _addToMemory(photoId, thumbBytes);
        return thumbBytes;
      }
    } catch (e) {
      debugPrint('Error in ThumbnailCacheService: $e');
    }

    return null;
  }

  void _addToMemory(String key, Uint8List bytes) {
    if (_memoryCache.length >= _maxMemoryEntries) {
      _memoryCache.remove(_memoryCache.keys.first); // Evict oldest
    }
    _memoryCache[key] = bytes;
  }

  Future<Directory> _getCacheDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final thumbDir = Directory(p.join(tempDir.path, 'thumbnails'));
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
    return thumbDir;
  }

  void clearMemory() {
    _memoryCache.clear();
  }
}
