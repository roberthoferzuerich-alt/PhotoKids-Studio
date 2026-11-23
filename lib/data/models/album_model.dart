import 'package:denis_phote_world/domain/entities/album_entity.dart';

class AlbumModel {
  final String id;
  final String name;
  final String? description;
  final String? coverPhotoPath;
  final DateTime createdAt;
  final int photoCount;
  final String iconEmoji;

  const AlbumModel({
    required this.id,
    required this.name,
    this.description,
    this.coverPhotoPath,
    required this.createdAt,
    this.photoCount = 0,
    this.iconEmoji = '📁',
  });

  factory AlbumModel.fromEntity(AlbumEntity entity) {
    return AlbumModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      coverPhotoPath: entity.coverPhotoPath,
      createdAt: entity.createdAt,
      photoCount: entity.photoCount,
      iconEmoji: entity.iconEmoji,
    );
  }

  AlbumEntity toEntity() {
    return AlbumEntity(
      id: id,
      name: name,
      description: description,
      coverPhotoPath: coverPhotoPath,
      createdAt: createdAt,
      photoCount: photoCount,
      iconEmoji: iconEmoji,
    );
  }

  factory AlbumModel.fromMap(Map<String, dynamic> map, {int photoCount = 0}) {
    return AlbumModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverPhotoPath: map['cover_photo_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      photoCount: photoCount,
      iconEmoji: map['icon_emoji'] as String? ?? '📁',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cover_photo_path': coverPhotoPath,
      'created_at': createdAt.toIso8601String(),
      'icon_emoji': iconEmoji,
    };
  }
}
