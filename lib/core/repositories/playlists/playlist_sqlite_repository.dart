import 'dart:collection';

import 'package:yampa/core/repositories/playlists/playlists.dart';
import 'package:yampa/core/utils/sqlite_utils.dart';
import 'package:yampa/models/playlist.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ulid/ulid.dart';

const String playlistsTableName = 'playlists';
const String playlistsTracksRelationsTableName = 'playlists_tracks_relation';

Future<void> _initializeDatabase(Database db) async {
  final futures = [
    db.execute('''
        CREATE TABLE IF NOT EXISTS $playlistsTableName (
          id TEXT PRIMARY KEY,
          name TEXT NULL,
          description TEXT NULL,
          image_path TEXT NULL,
          sort_mode INTEGER NULL
        )
      '''),
    db.execute('''
        CREATE TABLE IF NOT EXISTS $playlistsTracksRelationsTableName (
          id TEXT PRIMARY KEY,
          playlist_id TEXT NULL,
          track_id TEXT NULL
        )
      '''),
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
  Future<List<Playlist>> getPlaylists() async {
    final db = await _getdb();
    final playlists = await db.rawQuery('SELECT * FROM $playlistsTableName');
    final playlistTracks = await db.rawQuery(
      'SELECT * FROM $playlistsTracksRelationsTableName',
    );
    final Map<String, List<String>?> playlistTracksMap = HashMap();
    for (final row in playlistTracks) {
      if (playlistTracksMap[row["playlist_id"]] == null) {
        playlistTracksMap[row["playlist_id"].toString()] = [];
      }
      playlistTracksMap[row["playlist_id"]]?.add(row["track_id"].toString());
    }

    final List<Playlist> result = [];

    for (final playlistData in playlists) {
      final trackIds = playlistTracksMap[playlistData["id"]] ?? [];
      result.add(
        Playlist(
          id: playlistData["id"].toString(),
          name: playlistData["name"].toString(),
          description: playlistData["description"].toString(),
          imagePath: playlistData["image_path"]?.toString(),
          trackIds: trackIds,
          sortMode: playlistData["sort_mode"] != null
              ? SortMode.values[int.parse(playlistData["sort_mode"].toString())]
              : SortMode.titleAtoZ,
        ),
      );
    }

    return result;
  }

  @override
  Future<String> addPlaylist(Playlist playlist, {String? forceWithId}) async {
    final db = await _getdb();

    String effectiveId = Ulid().toString();
    if (playlist.id == favoritePlaylistId) {
      effectiveId = favoritePlaylistId;
    } else if (forceWithId != null) {
      effectiveId = forceWithId;
    }

    await db.insert(playlistsTableName, {
      'id': effectiveId,
      'name': playlist.name,
      'description': playlist.description,
      'image_path': playlist.imagePath,
      'sort_mode': playlist.sortMode.index,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    final batch = db.batch();
    for (final trackId in playlist.trackIds) {
      final id = Ulid().toString();
      batch.insert(
        playlistsTracksRelationsTableName,
        {'id': id, 'playlist_id': effectiveId, 'track_id': trackId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();

    return effectiveId;
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
        'sort_mode': playlist.sortMode.index,
      },
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
    await db.delete(
      playlistsTracksRelationsTableName,
      where: 'playlist_id = ?',
      whereArgs: [playlist.id],
    );

    final batch = db.batch();
    for (final trackId in playlist.trackIds) {
      final id = Ulid().toString();
      batch.insert(
        playlistsTracksRelationsTableName,
        {'id': id, 'playlist_id': playlist.id, 'track_id': trackId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit();
  }

  @override
  Future<void> addTrackToPlaylist(Playlist playlist, String trackId) async {
    final db = await _getdb();

    final id = Ulid().toString();
    await db.insert(
      playlistsTracksRelationsTableName,
      {'id': id, 'playlist_id': playlist.id, 'track_id': trackId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeTrackFromPlaylist(
    Playlist playlist,
    String trackId,
  ) async {
    final db = await _getdb();
    await db.delete(
      playlistsTracksRelationsTableName,
      where: 'playlist_id = ? and track_id = ?',
      whereArgs: [playlist.id, trackId],
    );
  }

  @override
  Future<void> removeMultipleTracksFromPlaylist(
    Playlist playlist,
    List<String> trackIds,
  ) async {
    final db = await _getdb();
    await db.delete(
      playlistsTracksRelationsTableName,
      where:
          'playlist_id = ? and track_id in (${List.filled(trackIds.length, '?').join(',')})',
      whereArgs: [playlist.id, ...trackIds],
    );
  }

  @override
  Future<void> removePlaylist(Playlist playlist) async {
    final db = await _getdb();
    final futures = [
      db.delete(playlistsTableName, where: 'id = ?', whereArgs: [playlist.id]),
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
  Future<void> linkTracksWithPlaylists(
    List<Map<String, String>> playlistAndTrackMapping,
  ) async {
    final db = await _getdb();

    final batch = db.batch();

    for (final row in playlistAndTrackMapping) {
      // Perhaps not the most optimal way to ensure no duplicated entries but it was convenient
      batch.delete(
        playlistsTracksRelationsTableName,
        where: 'playlist_id = ? and track_id = ?',
        whereArgs: [row["playlist_id"], row["track_id"]],
      );
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
