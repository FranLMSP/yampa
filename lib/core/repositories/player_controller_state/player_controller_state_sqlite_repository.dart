import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/repositories/player_controller_state/player_controller_state.dart';
import 'package:yampa/core/utils/sqlite_utils.dart';
import 'package:yampa/models/player_controller_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


const String playerControllerStateTableName = 'player_controller_state';

Future<void> _initializeDatabase(Database db) async {
  final futures = [
    db.execute(
      '''
        CREATE TABLE IF NOT EXISTS $playerControllerStateTableName (
          current_track_id TEXT NULL,
          current_playlist_id TEXT NULL,
          current_track_index TEXT NULL,
          speed REAL NULL,
          track_queue_ids TEXT NULL,
          shuffled_track_queue_ids TEXT NULL,
          state TEXT NULL,
          loop_mode TEXT NULL,
          shuffle_mode TEXT NULL
        )
      '''
    ),
  ];
  await Future.wait(futures);
}

class PlayerControllerStateSqliteRepository extends PlayerControllerStateRepository {
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
    final result = await db.rawQuery('SELECT * FROM $playerControllerStateTableName LIMIT 1');
    if (result.isNotEmpty) {
      final row = result[0];
      return LastPlayerControllerState(
        currentTrackId: row["current_track_id"]?.toString(),
        currentPlaylistId: row["current_playlist_id"]?.toString(),
        currentTrackIndex: row["current_track_index"] != null ? int.parse(row["current_track_index"].toString()) : 0,
        speed: row["speed"] != null ? double.parse(row["speed"].toString()) : 1,
        trackQueueIds: row["track_queue_ids"] != null ? row["track_queue_ids"].toString().split(",") : [],
        shuffledTrackQueueIds: row["shuffled_track_queue_ids"] != null ? row["shuffled_track_queue_ids"].toString().split(",") : [],
        state: row["state"] != null ? PlayerState.values[int.parse(row["state"].toString())] : PlayerState.stopped,
        loopMode: row["loop_mode"] != null ? LoopMode.values[int.parse(row["loop_mode"].toString())] : LoopMode.none,
        shuffleMode: row["shuffle_mode"] != null ? ShuffleMode.values[int.parse(row["shuffle_mode"].toString())] : ShuffleMode.sequential,
      );
    }
    return LastPlayerControllerState(
      currentTrackId: null,
      currentPlaylistId: null,
      currentTrackIndex: 0,
      speed: 1,
      trackQueueIds: [],
      shuffledTrackQueueIds: [],
      state: PlayerState.stopped,
      loopMode: LoopMode.none,
      shuffleMode: ShuffleMode.sequential, 
    );
  }

  @override
  Future<void> savePlayerControllerState(LastPlayerControllerState playerControllerState) async {
    final db = await _getdb();
    await db.delete(playerControllerStateTableName);
    await db.insert(
      playerControllerStateTableName,
      {
        "current_track_id": playerControllerState.currentTrackId,
        "current_track_index": playerControllerState.currentTrackIndex,
        "speed": playerControllerState.speed,
        "track_queue_ids": playerControllerState.trackQueueIds.join(","),
        "shuffled_track_queue_ids": playerControllerState.shuffledTrackQueueIds.join(","),
        "state": playerControllerState.state.index,
        "loop_mode": playerControllerState.loopMode.index,
        "shuffle_mode": playerControllerState.shuffleMode.index,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
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

