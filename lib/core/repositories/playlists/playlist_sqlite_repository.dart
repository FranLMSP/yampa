import 'dart:collection';

import 'package:yampa/core/repositories/playlists/playlists.dart';
import 'package:yampa/core/utils/sqlite_utils.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/models/track.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ulid/ulid.dart';


const String dbFilename = 'app_data.db';
const String playlistsTableName = 'playlists';
const String playlistsTracksRelationsTableName = 'playlists_tracks_relation';

Future<void> _initializeDatabase(Database db) async {
  final futures = [
    db.execute(
      '''
        CREATE TABLE IF NOT EXISTS $playlistsTableName (
          id TEXT PRIMARY KEY,
          name TEXT NULL,
          description TEXT NULL,
          image_path TEXT NULL
        )
      '''
    ),
    db.execute(
      '''
        CREATE TABLE IF NOT EXISTS $playlistsTracksRelationsTableName (
          id TEXT PRIMARY KEY,
          playlist_id TEXT NULL,
          track_id TEXT NULL
        )
      '''
    ),
  ];
  await Future.wait(futures);
}

class PlaylistSqliteRepository extends PlaylistsRepository {
  Database? _db;
  PlaylistSqliteRepository() {
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
  Future<List<Playlist>> getPlaylists(List<Track> tracks) async {
    final db = await _getdb();
    final playlists = await db.rawQuery('SELECT * FROM $playlistsTableName');
    final playlistTracks = await db.rawQuery('SELECT * FROM $playlistsTracksRelationsTableName');
    final Map<String, List<String>?> playlistTracksMap = HashMap();
    for (final row in playlistTracks) {
      if (playlistTracksMap[row["playlist_id"]] == null) {
        playlistTracksMap[row["playlist_id"].toString()] = [];
      }
      playlistTracksMap[row["playlist_id"]]?.add(row["track_id"].toString());
    }
    final Map<String, Track> tracksMap = HashMap();
    for (final track in tracks) {
      tracksMap[track.id] = track;
    }

    final List<Playlist> result = [];

    for (final playlistData in playlists) {
      final trackIds = playlistTracksMap[playlistData["id"]] ?? [];
      final List<Track> tracks = [];
      for (final trackId in trackIds) {
        final track = tracksMap[trackId];
        if (track != null) {
          tracks.add(track);
        }
      }
      result.add(
        Playlist(
          id: playlistData["id"].toString(),
          name: playlistData["name"].toString(),
          description: playlistData["description"].toString(),
          tracks: tracks,
        )
      );
    }

    return result;
  }

  @override
  Future<String> addPlaylist(Playlist playlist) async {
    final db = await _getdb();

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
    return id;
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    final db = await _getdb();
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
  }

  @override
  Future<void> addTrackToPlaylist(Playlist playlist, Track track) async {
    final db = await _getdb();

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
  }

  @override
  Future<void> removeTrackFromPlaylist(Playlist playlist, Track track) async {
    final db = await _getdb();
    await db.delete(
      playlistsTracksRelationsTableName,
      where: 'playlist_id = ? and track_id = ?',
      whereArgs: [playlist.id, track.id],
    );
  }

  @override
  Future<void> removePlaylist(Playlist playlist) async {
    final db = await _getdb();
    final futures = [
      db.delete(
        playlistsTableName,
        where: 'id = ?',
        whereArgs: [playlist.id],
      ),
      db.delete(
        playlistsTracksRelationsTableName,
        where: 'playlist_id = ?',
        whereArgs: [playlist.id],
      ),
    ];
    await Future.wait(futures);
  }

  @override
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  @override
  Future<void> linkTracksWithPlaylists(List<Map<String, String>> playlistAndTrackMapping) async {
    final db = await _getdb();

    final batch = db.batch();

    for (final row in playlistAndTrackMapping) {
      final id = Ulid().toString();
      batch.insert(
        playlistsTracksRelationsTableName,
        {
          'id': id,
          'playlist_id': row["playlist_id"],
          'track_id': row["track_id"],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }
}
