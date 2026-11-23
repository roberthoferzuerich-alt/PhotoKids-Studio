import 'package:equatable/equatable.dart';

enum PhotoFlag {
  none,
  favorite,
  important,
  editLater,
}

class PhotoEntity extends Equatable {
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

  const PhotoEntity({
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

  bool get isFavorite => flag == PhotoFlag.favorite;
  bool get isImportant => flag == PhotoFlag.important;
  bool get isEditLater => flag == PhotoFlag.editLater;

  /// Returns remaining days before deletion in trash (30 days total)
  int get remainingTrashDays {
    if (deletedAt == null) return 30;
    final deadline = deletedAt!.add(const Duration(days: 30));
    final diff = deadline.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  PhotoEntity copyWith({
    String? id,
    String? filePath,
    String? fileName,
    String? fileExtension,
    int? fileSizeBytes,
    int? width,
    int? height,
    DateTime? dateTaken,
    DateTime? dateAdded,
    PhotoFlag? flag,
    bool? isDeleted,
    DateTime? deletedAt,
    String? albumId,
    List<String>? tags,
    String? category,
    String? thumbnailPath,
    Map<String, dynamic>? exifData,
  }) {
    return PhotoEntity(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileExtension: fileExtension ?? this.fileExtension,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      dateTaken: dateTaken ?? this.dateTaken,
      dateAdded: dateAdded ?? this.dateAdded,
      flag: flag ?? this.flag,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      albumId: albumId ?? this.albumId,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      exifData: exifData ?? this.exifData,
    );
  }

  @override
  List<Object?> get props => [
        id,
        filePath,
        fileName,
        fileExtension,
        fileSizeBytes,
        width,
        height,
        dateTaken,
        dateAdded,
        flag,
        isDeleted,
        deletedAt,
        albumId,
        tags,
        category,
        thumbnailPath,
      ];
}
