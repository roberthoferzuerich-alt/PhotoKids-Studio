import 'package:sqflite/sqflite.dart';
import 'package:photokids_studio/core/database/database_service.dart';
import 'package:photokids_studio/data/models/photo_model.dart';
import 'package:photokids_studio/domain/entities/photo_entity.dart';

class PhotoLocalDatasource {
  Future<Database> get _db => DatabaseService.database;

  Future<List<PhotoModel>> getAllPhotos({bool includeDeleted = false}) async {
    final db = await _db;
    final where = includeDeleted ? null : 'is_deleted = 0';
    final result = await db.query(
      'photos',
      where: where,
      orderBy: 'date_taken DESC',
    );
    return result.map((m) => PhotoModel.fromMap(m)).toList();
  }

  Future<PhotoModel?> getPhotoById(String id) async {
    final db = await _db;
    final result = await db.query('photos', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;
    return PhotoModel.fromMap(result.first);
  }

  Future<List<PhotoModel>> getPhotosByAlbum(String albumId) async {
    final db = await _db;
    final result = await db.query(
      'photos',
      where: 'album_id = ? AND is_deleted = 0',
      whereArgs: [albumId],
      orderBy: 'date_taken DESC',
    );
    return result.map((m) => PhotoModel.fromMap(m)).toList();
  }

  Future<List<PhotoModel>> getFavoritePhotos() async {
    final db = await _db;
    final result = await db.query(
      'photos',
      where: 'flag = ? AND is_deleted = 0',
      whereArgs: [PhotoFlag.favorite.index],
      orderBy: 'date_taken DESC',
    );
    return result.map((m) => PhotoModel.fromMap(m)).toList();
  }

  Future<List<PhotoModel>> getTrashPhotos() async {
    final db = await _db;
    final result = await db.query(
      'photos',
      where: 'is_deleted = 1',
      orderBy: 'deleted_at DESC',
    );
    return result.map((m) => PhotoModel.fromMap(m)).toList();
  }

  Future<List<PhotoModel>> searchPhotos({String? query, List<String>? tags, String? category}) async {
    final db = await _db;
    final conditions = <String>['is_deleted = 0'];
    final args = <dynamic>[];

    if (query != null && query.trim().isNotEmpty) {
      conditions.add('(file_name LIKE ? OR tags LIKE ? OR category LIKE ?)');
      final term = '%${query.trim()}%';
      args.addAll([term, term, term]);
    }

    if (category != null && category.isNotEmpty) {
      conditions.add('category = ?');
      args.add(category);
    }

    final whereClause = conditions.join(' AND ');
    final result = await db.query(
      'photos',
      where: whereClause,
      whereArgs: args,
      orderBy: 'date_taken DESC',
    );

    var list = result.map((m) => PhotoModel.fromMap(m)).toList();

    if (tags != null && tags.isNotEmpty) {
      list = list.where((p) => tags.any((tag) => p.tags.contains(tag))).toList();
    }

    return list;
  }

  Future<void> insertPhoto(PhotoModel photo) async {
    final db = await _db;
    await db.insert('photos', photo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePhoto(PhotoModel photo) async {
    final db = await _db;
    await db.update('photos', photo.toMap(), where: 'id = ?', whereArgs: [photo.id]);
  }

  Future<void> moveToTrash(String id) async {
    final db = await _db;
    await db.update(
      'photos',
      {
        'is_deleted': 1,
        'deleted_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> restoreFromTrash(String id) async {
    final db = await _db;
    await db.update(
      'photos',
      {
        'is_deleted': 0,
        'deleted_at': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePermanently(String id) async {
    final db = await _db;
    await db.delete('photos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cleanExpiredTrash(int retentionDays) async {
    final db = await _db;
    final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays)).toIso8601String();
    await db.delete('photos', where: 'is_deleted = 1 AND deleted_at < ?', whereArgs: [cutoffDate]);
  }

  Future<void> setPhotoFlag(String id, PhotoFlag flag) async {
    final db = await _db;
    await db.update(
      'photos',
      {'flag': flag.index},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> assignToAlbum(String photoId, String? albumId) async {
    final db = await _db;
    await db.update(
      'photos',
      {'album_id': albumId},
      where: 'id = ?',
      whereArgs: [photoId],
    );
  }

  Future<int> getTotalPhotoCount() async {
    final db = await _db;
    final res = await db.rawQuery('SELECT COUNT(*) as count FROM photos WHERE is_deleted = 0');
    return Sqflite.firstIntValue(res) ?? 0;
  }
}
