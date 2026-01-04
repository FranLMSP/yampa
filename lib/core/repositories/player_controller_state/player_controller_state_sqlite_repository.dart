import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/repositories/player_controller_state/player_controller_state.dart';
import 'package:yampa/core/utils/sqlite_utils.dart';
import 'package:yampa/models/player_controller_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String playerControllerStateTableName = 'player_controller_state';

Future<void> _initializeDatabase(Database db) async {
  final futures = [
    db.execute('''
        CREATE TABLE IF NOT EXISTS $playerControllerStateTableName (
          current_track_id TEXT NULL,
          current_playlist_id TEXT NULL,
          speed REAL NULL,
          track_queue_ids TEXT NULL,
          shuffled_track_queue_ids TEXT NULL,
          state TEXT NULL,
          loop_mode TEXT NULL,
          shuffle_mode TEXT NULL,
          track_queue_display_mode TEXT NULL,
          volume REAL NULL,
          equalizer_gains TEXT NULL
        )
      '''),
  ];
  await Future.wait(futures);
}

class PlayerControllerStateSqliteRepository
    extends PlayerControllerStateRepository {
  Database? _db;
  PlayerControllerStateSqliteRepository() {
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
  Future<LastPlayerControllerState> getPlayerControllerState() async {
    final db = await _getdb();
    final result = await db.rawQuery(
      'SELECT * FROM $playerControllerStateTableName LIMIT 1',
    );
    if (result.isNotEmpty) {
      final row = result[0];
      return LastPlayerControllerState(
        currentTrackId: row["current_track_id"]?.toString(),
        currentPlaylistId: row["current_playlist_id"]?.toString(),
        speed: row["speed"] != null ? double.parse(row["speed"].toString()) : 1,
        trackQueueIds: row["track_queue_ids"] != null
            ? row["track_queue_ids"].toString().split(",")
            : [],
        shuffledTrackQueueIds: row["shuffled_track_queue_ids"] != null
            ? row["shuffled_track_queue_ids"].toString().split(",")
            : [],
        state: row["state"] != null
            ? PlayerState.values[int.parse(row["state"].toString())]
            : PlayerState.stopped,
        loopMode: row["loop_mode"] != null
            ? LoopMode.values[int.parse(row["loop_mode"].toString())]
            : LoopMode.infinite,
        shuffleMode: row["shuffle_mode"] != null
            ? ShuffleMode.values[int.parse(row["shuffle_mode"].toString())]
            : ShuffleMode.random,
        trackQueueDisplayMode: row["track_queue_display_mode"] != null
            ? TrackQueueDisplayMode.values[int.parse(
                row["track_queue_display_mode"].toString(),
              )]
            : TrackQueueDisplayMode.image,
        volume: row["volume"] != null
            ? double.parse(row["volume"].toString())
            : 1.0,
        equalizerGains: row["equalizer_gains"] != null
            ? row["equalizer_gains"]
                  .toString()
                  .split(",")
                  .map((e) => double.tryParse(e))
                  .whereType<double>()
                  .toList()
            : [],
      );
    }
    return LastPlayerControllerState(
      currentTrackId: null,
      currentPlaylistId: null,
      speed: 1,
      trackQueueIds: [],
      shuffledTrackQueueIds: [],
      state: PlayerState.stopped,
      loopMode: LoopMode.infinite,
      shuffleMode: ShuffleMode.random,
      trackQueueDisplayMode: TrackQueueDisplayMode.image,
      volume: 1.0,
      equalizerGains: [],
    );
  }

  @override
  Future<void> savePlayerControllerState(
    LastPlayerControllerState playerControllerState,
  ) async {
    final db = await _getdb();
    await db.delete(playerControllerStateTableName);
    await db.insert(playerControllerStateTableName, {
      "current_track_id": playerControllerState.currentTrackId,
      "current_playlist_id": playerControllerState.currentPlaylistId,
      "speed": playerControllerState.speed,
      "track_queue_ids": playerControllerState.trackQueueIds.join(","),
      "shuffled_track_queue_ids": playerControllerState.shuffledTrackQueueIds
          .join(","),
      "state": playerControllerState.state.index,
      "loop_mode": playerControllerState.loopMode.index,
      "shuffle_mode": playerControllerState.shuffleMode.index,
      "track_queue_display_mode":
          playerControllerState.trackQueueDisplayMode.index,
      "volume": playerControllerState.volume,
      "equalizer_gains": playerControllerState.equalizerGains.join(","),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
