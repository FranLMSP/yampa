import 'package:music_player/core/utils/sqlite_utils.dart';
import 'package:music_player/core/repositories/stored_paths/stored_paths.dart';
import 'package:music_player/models/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ulid/ulid.dart';

const String storedPathsFilename = 'app_data.db';
const String storedPathsTableName = 'added_paths';

Future<void> _initializeDatabase(Database db) async {
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

  @override
  Future<List<GenericPath>> getStoredPaths() async {
    var db = await openSqliteDatabase();
    await _initializeDatabase(db);
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
    var db = await openSqliteDatabase();
    await _initializeDatabase(db);
    if (await _doesPathAlreadyExist(path, db)) {
      return;
    }

    await db.insert(
      storedPathsTableName,
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
    var db = await openSqliteDatabase();
    await _initializeDatabase(db);
    await db.delete(
      storedPathsTableName,
      where: 'id = ?',
      whereArgs: [path.id],
    );
    await db.close();
  }
}
