import 'package:music_player/core/repositories/playlists/playlists.dart';
import 'package:music_player/core/utils/sqlite_utils.dart';
import 'package:music_player/models/playlist.dart';
import 'package:music_player/models/track.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ulid/ulid.dart';


const String dbFilename = 'app_data.db';
const String playlistsTableName = 'playlists';
const String playlistsTracksRelationsTableName = 'playlists_tracks_relation';

Future<void> _initializeDatabase(Database db) async {
  // TODO: add foreign keys to playlists_tracks_relation
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $playlistsTableName (
      id TEXT PRIMARY KEY,
      name TEXT NULL,
      description TEXT NULL,
      image_path TEXT NULL
    )

    CREATE TABLE IF NOT EXISTS $playlistsTracksRelationsTableName (
      id TEXT PRIMARY KEY,
      playlist_id TEXT NULL,
      track_id TEXT NULL
    )
  ''');
}

class PlaylistSqliteRepository extends PlaylistsRepository {
  PlaylistSqliteRepository() {
    sqfliteFfiInit();
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    return [];
  }

  @override
  Future<String> addPlaylist(Playlist playlist) async {
    var db = await openSqliteDatabase();
    await _initializeDatabase(db);

    final id = Ulid().toString();
    await db.insert(
      playlistsTableName,
      {
        'id': id,
        'name': playlist.name,
        'description': playlist.description,
        'image_path': playlist.imagePath,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.close();
    return id;
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    var db = await openSqliteDatabase();
    await _initializeDatabase(db);
    await db.update(
      playlistsTableName,
      {
        'name': playlist.name,
        'description': playlist.description,
        'image_path': playlist.imagePath,
      },
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
    await db.close();
  }

  @override
  Future<void> addTrackToPlaylist(Playlist playlist, Track track) async {
    var db = await openSqliteDatabase();
    await _initializeDatabase(db);

    final id = Ulid().toString();
    await db.insert(
      playlistsTracksRelationsTableName,
      {
        'id': id,
        'playlist_id': playlist.id,
        'track_id': track.id,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db.close();
  }

  @override
  Future<void> removeTrackFromPlaylist(Playlist playlist, Track track) async {
    var db = await openSqliteDatabase();
    await _initializeDatabase(db);
    await db.delete(
      playlistsTracksRelationsTableName,
      where: 'playlist_id = ? and track_id = ?',
      whereArgs: [playlist.id, track.id],
    );
    await db.close();
  }

  @override
  Future<void> removePlaylist(Playlist playlist) async {
    var db = await openSqliteDatabase();
    await _initializeDatabase(db);
    // TODO: perform these two delete statements at the same time
    await db.delete(
      playlistsTableName,
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
    await db.delete(
      playlistsTracksRelationsTableName,
      where: 'playlist_id = ?',
      whereArgs: [playlist.id],
    );
    await db.close();
  }
}
