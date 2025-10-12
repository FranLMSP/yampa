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
  Database? _db;
  StoredPathsSqlite() {
    sqfliteFfiInit();
  }

  Future<Database> _getdb() async {
    Database? db;
    if (_db != null) {
      db = _db;
    } else {
      db = await openSqliteDatabase();
      await _initializeDatabase(db);
    }

    return db!;
  }

  @override
  Future<List<GenericPath>> getStoredPaths() async {
    final db = await _getdb();
    final results = await db.rawQuery('SELECT * FROM $storedPathsTableName');
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
  Future<String> addPath(GenericPath path) async {
    final db = await _getdb();
    if (await _doesPathAlreadyExist(path, db)) {
      return "";
    }

    final id = Ulid().toString();
    await db.insert(
      storedPathsTableName,
      {
        'id': id,
        'folder': path.folder,
        'filename': path.filename,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }

  @override
  Future<void> removePath(GenericPath path) async {
    if (path.id.trim().isEmpty) return;
    final db = await _getdb();
    await db.delete(
      storedPathsTableName,
      where: 'id = ?',
      whereArgs: [path.id],
    );
  }

  @override
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
