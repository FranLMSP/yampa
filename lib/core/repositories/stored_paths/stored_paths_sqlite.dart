import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:music_player/core/repositories/stored_paths/stored_paths.dart';
import 'package:music_player/models/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ulid/ulid.dart';

const String storedPathsFilename = 'stored_paths.db';
const String storedPathsTableName = 'added_paths';

Future<void> initializeDatabase(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $storedPathsTableName (
      id TEXT PRIMARY KEY,
      folder TEXT NULL,
      filename TEXT NULL
    )
  ''');
}

class StoredPathsSqlite extends StoredPaths {
  StoredPathsSqlite() {
    sqfliteFfiInit();
  }

  Future<Database> _openDatabase() async {
    // TODO: for Linux, use ~/.local/share/yampa
    // For Windows we could use %AppData%
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = p.join(appDocumentsDir.path, "databases", storedPathsFilename);
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase(dbPath);
    await initializeDatabase(db);
    return db;
  }

  @override
  Future<List<GenericPath>> getStoredPaths() async {
    var db = await _openDatabase();
    final results = await db.rawQuery('SELECT * FROM $storedPathsTableName');
    await db.close();
    return results.map((row) => GenericPath(
      id: row['id'].toString(),
      folder: row['folder']?.toString(),
      filename: row['filename']?.toString(),
    )).toList();
  }

  Future <bool> _doesPathAlreadyExist(GenericPath path, Database db) async {
    if (path.filename != null) {
      final foundPathsByFilename = await db.rawQuery(
        'SELECT * FROM $storedPathsTableName WHERE filename = ?',
        [path.filename]
      );
      return foundPathsByFilename.isNotEmpty;
    } else if (path.folder != null ) {
      final foundPathsByFolder = await db.rawQuery(
        'SELECT * FROM $storedPathsTableName WHERE folder = ?',
        [path.folder]
      );
      return foundPathsByFolder.isNotEmpty;
    }
    return false;
  }

  @override
  Future<void> addPath(GenericPath path) async {
    var db = await _openDatabase();
    if (await _doesPathAlreadyExist(path, db)) {
      return;
    }

    await db.insert(
      'added_paths',
      {
        'id': Ulid().toString(),
        'folder': path.folder,
        'filename': path.filename,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.close();
  }

  @override
  Future<void> removePath(GenericPath path) async {
    if (path.id.trim().isEmpty) return;
    var db = await _openDatabase();
    await db.delete(
      storedPathsTableName,
      where: 'id = ?',
      whereArgs: [path.id],
    );
    await db.close();
  }
}
