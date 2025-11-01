import 'package:yampa/core/repositories/favorite_tracks/favorite_tracks.dart';
import 'package:yampa/core/utils/sqlite_utils.dart';
import 'package:yampa/models/track.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ulid/ulid.dart';


const String favoriteTracksTableName = 'favorite_tracks';

Future<void> _initializeDatabase(Database db) async {
  final futures = [
    db.execute(
      '''
        CREATE TABLE IF NOT EXISTS $favoriteTracksTableName (
          id TEXT PRIMARY KEY,
          track_id TEXT NULL
        )
      '''
    ),
  ];
  await Future.wait(futures);
}

class FavoriteTracksSqliteRepository extends FavoriteTracksRepository {
  Database? _db;
  FavoriteTracksSqliteRepository() {
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
  Future<List<String>> getFavoriteTrackIds() async {
    final db = await _getdb();
    final favoriteTracks = await db.rawQuery('SELECT * FROM $favoriteTracksTableName');
    List<String> result = [];
    for (final row in favoriteTracks) {
      if (row["track_id"] == null) {
        continue;
      }
      result.add(row["track_id"].toString());
    }

    return result;
  }

  @override
  Future<void> addFavoriteTracks(List<Track> tracks) async {
    final db = await _getdb();

    final batch = db.batch();
    for (final track in tracks) {
      final id = Ulid().toString();
      batch.insert(
        favoriteTracksTableName,
        {
          'id': id,
          'track_id': track.id,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  @override
  Future<void> removeTracksFromFavorites(List<Track> tracks) async {
    final db = await _getdb();
    final idsToDelete = tracks.map((e) => e.id).toList();
    await db.delete(
      favoriteTracksTableName,
      where: 'track_id in (${List.filled(idsToDelete.length, '?').join(',')})',
      whereArgs: idsToDelete,
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
