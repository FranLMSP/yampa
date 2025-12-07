import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yampa/core/repositories/cached_tracks/cached_tracks.dart';
import 'package:yampa/core/utils/sqlite_utils.dart';
import 'package:yampa/models/track.dart';

const String cachedTracksTableName = 'cached_tracks';

Future<void> _initializeDatabase(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $cachedTracksTableName (
      id TEXT PRIMARY KEY,
      name TEXT,
      artist TEXT,
      album TEXT,
      genre TEXT,
      path TEXT,
      trackNumber INTEGER,
      duration INTEGER,
      imageBytes BLOB,
      lastModified INTEGER
    )
  ''');
}

class CachedTracksSqlite extends CachedTracksRepository {
  Database? _db;

  CachedTracksSqlite() {
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
  Future<List<Track>> getAll() async {
    final db = await _getdb();
    final results = await db.query(cachedTracksTableName);
    return results
        .map(
          (row) => Track(
            id: row['id'] as String,
            name: row['name'] as String,
            artist: row['artist'] as String,
            album: row['album'] as String,
            genre: row['genre'] as String,
            path: row['path'] as String,
            trackNumber: row['trackNumber'] as int,
            duration: Duration(milliseconds: row['duration'] as int),
            imageBytes: row['imageBytes'] as dynamic,
            lastModified: row['lastModified'] != null
                ? DateTime.fromMillisecondsSinceEpoch(
                    row['lastModified'] as int,
                  )
                : null,
          ),
        )
        .toList();
  }

  @override
  Future<void> addOrUpdate(Track track) async {
    final db = await _getdb();
    await db.insert(cachedTracksTableName, {
      'id': track.id,
      'name': track.name,
      'artist': track.artist,
      'album': track.album,
      'genre': track.genre,
      'path': track.path,
      'trackNumber': track.trackNumber,
      'duration': track.duration.inMilliseconds,
      'imageBytes': track.imageBytes,
      'lastModified': track.lastModified?.millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> remove(String path) async {
    final db = await _getdb();
    await db.delete(
      cachedTracksTableName,
      where: 'path = ?',
      whereArgs: [path],
    );
  }

  @override
  Future<void> removeAll() async {
    final db = await _getdb();
    await db.delete(cachedTracksTableName);
  }

  @override
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
