import 'package:sqflite/sqflite.dart';
import 'package:photokids_studio/core/database/database_service.dart';
import 'package:photokids_studio/data/models/album_model.dart';

class AlbumLocalDatasource {
  Future<Database> get _db => DatabaseService.database;

  Future<List<AlbumModel>> getAllAlbums() async {
    final db = await _db;
    final albumRecords = await db.query('albums', orderBy: 'created_at DESC');

    final list = <AlbumModel>[];
    for (final map in albumRecords) {
      final albumId = map['id'] as String;
      final countRes = await db.rawQuery(
        'SELECT COUNT(*) as count FROM photos WHERE album_id = ? AND is_deleted = 0',
        [albumId],
      );
      final count = Sqflite.firstIntValue(countRes) ?? 0;
      list.add(AlbumModel.fromMap(map, photoCount: count));
    }
    return list;
  }

  Future<AlbumModel?> getAlbumById(String id) async {
    final db = await _db;
    final result = await db.query('albums', where: 'id = ?', whereArgs: [id], limit: 1);
    if (result.isEmpty) return null;

    final countRes = await db.rawQuery(
      'SELECT COUNT(*) as count FROM photos WHERE album_id = ? AND is_deleted = 0',
      [id],
    );
    final count = Sqflite.firstIntValue(countRes) ?? 0;
    return AlbumModel.fromMap(result.first, photoCount: count);
  }

  Future<void> insertAlbum(AlbumModel album) async {
    final db = await _db;
    await db.insert('albums', album.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateAlbum(AlbumModel album) async {
    final db = await _db;
    await db.update('albums', album.toMap(), where: 'id = ?', whereArgs: [album.id]);
  }

  Future<void> deleteAlbum(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      // Unlink photos from this album
      await txn.update('photos', {'album_id': null}, where: 'album_id = ?', whereArgs: [id]);
      await txn.delete('albums', where: 'id = ?', whereArgs: [id]);
    });
  }
}
