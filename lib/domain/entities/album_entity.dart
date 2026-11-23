import 'package:equatable/equatable.dart';

class AlbumEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverPhotoPath;
  final DateTime createdAt;
  final int photoCount;
  final String iconEmoji;

  const AlbumEntity({
    required this.id,
    required this.name,
    this.description,
    this.coverPhotoPath,
    required this.createdAt,
    this.photoCount = 0,
    this.iconEmoji = '📁',
  });

  AlbumEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? coverPhotoPath,
    DateTime? createdAt,
    int? photoCount,
    String? iconEmoji,
  }) {
    return AlbumEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      createdAt: createdAt ?? this.createdAt,
      photoCount: photoCount ?? this.photoCount,
      iconEmoji: iconEmoji ?? this.iconEmoji,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        coverPhotoPath,
        createdAt,
        photoCount,
        iconEmoji,
      ];
}
