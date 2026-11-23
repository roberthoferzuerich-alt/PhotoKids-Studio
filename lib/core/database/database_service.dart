import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'photokids_studio.db';
  static const int _dbVersion = 1;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        _dbName,
        options: OpenDatabaseOptions(
          version: _dbVersion,
          onCreate: _onCreate,
        ),
      );
    } else {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(appDocDir.path, _dbName);

      return await openDatabase(
        dbPath,
        version: _dbVersion,
        onCreate: _onCreate,
      );
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Photos table
    await db.execute('''
      CREATE TABLE photos (
        id TEXT PRIMARY KEY,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_extension TEXT NOT NULL,
        file_size_bytes INTEGER NOT NULL,
        width INTEGER NOT NULL,
        height INTEGER NOT NULL,
        date_taken TEXT NOT NULL,
        date_added TEXT NOT NULL,
        flag INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        deleted_at TEXT,
        album_id TEXT,
        tags TEXT,
        category TEXT,
        thumbnail_path TEXT,
        exif_data TEXT
      )
    ''');

    // Albums table
    await db.execute('''
      CREATE TABLE albums (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        cover_photo_path TEXT,
        created_at TEXT NOT NULL,
        icon_emoji TEXT NOT NULL DEFAULT '📁'
      )
    ''');

    // Performance Indexes for 10.000+ images
    await db.execute('CREATE INDEX idx_photos_is_deleted ON photos(is_deleted);');
    await db.execute('CREATE INDEX idx_photos_album_id ON photos(album_id);');
    await db.execute('CREATE INDEX idx_photos_flag ON photos(flag);');
    await db.execute('CREATE INDEX idx_photos_date_taken ON photos(date_taken DESC);');
    await db.execute('CREATE INDEX idx_photos_file_name ON photos(file_name);');
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
