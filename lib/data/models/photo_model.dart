import 'dart:convert';
import 'package:photokids_studio/domain/entities/photo_entity.dart';

class PhotoModel {
  final String id;
  final String filePath;
  final String fileName;
  final String fileExtension;
  final int fileSizeBytes;
  final int width;
  final int height;
  final DateTime dateTaken;
  final DateTime dateAdded;
  final PhotoFlag flag;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? albumId;
  final List<String> tags;
  final String? category;
  final String? thumbnailPath;
  final Map<String, dynamic> exifData;

  const PhotoModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.fileExtension,
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    required this.dateTaken,
    required this.dateAdded,
    this.flag = PhotoFlag.none,
    this.isDeleted = false,
    this.deletedAt,
    this.albumId,
    this.tags = const [],
    this.category,
    this.thumbnailPath,
    this.exifData = const {},
  });

  factory PhotoModel.fromEntity(PhotoEntity entity) {
    return PhotoModel(
      id: entity.id,
      filePath: entity.filePath,
      fileName: entity.fileName,
      fileExtension: entity.fileExtension,
      fileSizeBytes: entity.fileSizeBytes,
      width: entity.width,
      height: entity.height,
      dateTaken: entity.dateTaken,
      dateAdded: entity.dateAdded,
      flag: entity.flag,
      isDeleted: entity.isDeleted,
      deletedAt: entity.deletedAt,
      albumId: entity.albumId,
      tags: entity.tags,
      category: entity.category,
      thumbnailPath: entity.thumbnailPath,
      exifData: entity.exifData,
    );
  }

  PhotoEntity toEntity() {
    return PhotoEntity(
      id: id,
      filePath: filePath,
      fileName: fileName,
      fileExtension: fileExtension,
      fileSizeBytes: fileSizeBytes,
      width: width,
      height: height,
      dateTaken: dateTaken,
      dateAdded: dateAdded,
      flag: flag,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      albumId: albumId,
      tags: tags,
      category: category,
      thumbnailPath: thumbnailPath,
      exifData: exifData,
    );
  }

  factory PhotoModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map['tags'] != null && map['tags'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(map['tags'] as String);
        if (decoded is List) {
          parsedTags = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedTags = (map['tags'] as String).split(',');
      }
    }

    Map<String, dynamic> parsedExif = {};
    if (map['exif_data'] != null && map['exif_data'].toString().isNotEmpty) {
      try {
        parsedExif = jsonDecode(map['exif_data'] as String);
      } catch (_) {}
    }

    return PhotoModel(
      id: map['id'] as String,
      filePath: map['file_path'] as String,
      fileName: map['file_name'] as String,
      fileExtension: map['file_extension'] as String,
      fileSizeBytes: map['file_size_bytes'] as int,
      width: map['width'] as int,
      height: map['height'] as int,
      dateTaken: DateTime.parse(map['date_taken'] as String),
      dateAdded: DateTime.parse(map['date_added'] as String),
      flag: PhotoFlag.values[map['flag'] as int? ?? 0],
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
      deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
      albumId: map['album_id'] as String?,
      tags: parsedTags,
      category: map['category'] as String?,
      thumbnailPath: map['thumbnail_path'] as String?,
      exifData: parsedExif,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'file_path': filePath,
      'file_name': fileName,
      'file_extension': fileExtension,
      'file_size_bytes': fileSizeBytes,
      'width': width,
      'height': height,
      'date_taken': dateTaken.toIso8601String(),
      'date_added': dateAdded.toIso8601String(),
      'flag': flag.index,
      'is_deleted': isDeleted ? 1 : 0,
      'deleted_at': deletedAt?.toIso8601String(),
      'album_id': albumId,
      'tags': jsonEncode(tags),
      'category': category,
      'thumbnail_path': thumbnailPath,
      'exif_data': jsonEncode(exifData),
    };
  }
}
