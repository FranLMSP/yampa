import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yampa/core/repositories/statistics/statistics.dart';
import 'package:yampa/core/utils/sqlite_utils.dart';
import 'package:yampa/models/player_statistics.dart';
import 'package:yampa/models/track_statistics.dart';

const String playerStatisticsTableName = 'player_statistics';
const String trackStatisticsTableName = 'track_statistics';

Future<void> _initializeDatabase(Database db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS $playerStatisticsTableName (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      totalMinutesPlayed REAL DEFAULT 0,
      totalTracksPlayed INTEGER DEFAULT 0,
      totalUniqueTracksPlayed INTEGER DEFAULT 0,
      uptime INTEGER DEFAULT 0,
      timesStarted INTEGER DEFAULT 0,
      lastPlayedAt INTEGER,
      totalSkips INTEGER DEFAULT 0
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS $trackStatisticsTableName (
      trackId TEXT PRIMARY KEY,
      timesPlayed INTEGER DEFAULT 0,
      timesSkipped INTEGER DEFAULT 0,
      minutesPlayed REAL DEFAULT 0,
      lastPlayedAt INTEGER,
      completionCount INTEGER DEFAULT 0
    )
  ''');

  // Initialize player statistics row if it doesn't exist
  await db.insert(
    playerStatisticsTableName,
    {
      'id': 1,
      'totalMinutesPlayed': 0.0,
      'totalTracksPlayed': 0,
      'totalUniqueTracksPlayed': 0,
      'uptime': 0,
      'timesStarted': 0,
      'lastPlayedAt': null,
      'totalSkips': 0,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

class StatisticsSqlite extends StatisticsRepository {
  Database? _db;

  StatisticsSqlite() {
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
  Future<PlayerStatistics> getPlayerStatistics() async {
    final db = await _getdb();
    final results = await db.query(
      playerStatisticsTableName,
      where: 'id = ?',
      whereArgs: [1],
    );

    if (results.isEmpty) {
      return PlayerStatistics.empty();
    }

    final row = results.first;
    return PlayerStatistics(
      totalMinutesPlayed: row['totalMinutesPlayed'] as double,
      totalTracksPlayed: row['totalTracksPlayed'] as int,
      totalUniqueTracksPlayed: row['totalUniqueTracksPlayed'] as int,
      uptime: Duration(milliseconds: row['uptime'] as int),
      timesStarted: row['timesStarted'] as int,
      lastPlayedAt: row['lastPlayedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['lastPlayedAt'] as int)
          : null,
      totalSkips: row['totalSkips'] as int,
    );
  }

  @override
  Future<void> updatePlayerStatistics(PlayerStatistics stats) async {
    final db = await _getdb();
    await db.update(
      playerStatisticsTableName,
      {
        'totalMinutesPlayed': stats.totalMinutesPlayed,
        'totalTracksPlayed': stats.totalTracksPlayed,
        'totalUniqueTracksPlayed': stats.totalUniqueTracksPlayed,
        'uptime': stats.uptime.inMilliseconds,
        'timesStarted': stats.timesStarted,
        'lastPlayedAt': stats.lastPlayedAt?.millisecondsSinceEpoch,
        'totalSkips': stats.totalSkips,
      },
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  @override
  Future<void> incrementTimesStarted() async {
    final db = await _getdb();
    await db.rawUpdate('''
      UPDATE $playerStatisticsTableName
      SET timesStarted = timesStarted + 1
      WHERE id = 1
    ''');
  }

  @override
  Future<void> addPlaybackTime(Duration duration) async {
    final db = await _getdb();
    final minutes = duration.inSeconds / 60.0;
    await db.rawUpdate('''
      UPDATE $playerStatisticsTableName
      SET totalMinutesPlayed = totalMinutesPlayed + ?,
          uptime = uptime + ?,
          lastPlayedAt = ?
      WHERE id = 1
    ''', [minutes, duration.inMilliseconds, DateTime.now().millisecondsSinceEpoch]);
  }

  @override
  Future<void> incrementTotalSkips() async {
    final db = await _getdb();
    await db.rawUpdate('''
      UPDATE $playerStatisticsTableName
      SET totalSkips = totalSkips + 1
      WHERE id = 1
    ''');
  }

  @override
  Future<void> recordTrackPlayed(String trackId) async {
    final db = await _getdb();
    
    // Check if this is a new unique track
    final trackStats = await getTrackStatistics(trackId);
    final isNewTrack = trackStats.timesPlayed == 0;
    
    await db.rawUpdate('''
      UPDATE $playerStatisticsTableName
      SET totalTracksPlayed = totalTracksPlayed + 1,
          totalUniqueTracksPlayed = totalUniqueTracksPlayed + ?,
          lastPlayedAt = ?
      WHERE id = 1
    ''', [isNewTrack ? 1 : 0, DateTime.now().millisecondsSinceEpoch]);
  }

  @override
  Future<TrackStatistics> getTrackStatistics(String trackId) async {
    final db = await _getdb();
    final results = await db.query(
      trackStatisticsTableName,
      where: 'trackId = ?',
      whereArgs: [trackId],
    );

    if (results.isEmpty) {
      return TrackStatistics.empty(trackId);
    }

    final row = results.first;
    return TrackStatistics(
      trackId: row['trackId'] as String,
      timesPlayed: row['timesPlayed'] as int,
      timesSkipped: row['timesSkipped'] as int,
      minutesPlayed: row['minutesPlayed'] as double,
      lastPlayedAt: row['lastPlayedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['lastPlayedAt'] as int)
          : null,
      completionCount: row['completionCount'] as int,
    );
  }

  @override
  Future<Map<String, TrackStatistics>> getAllTrackStatistics() async {
    final db = await _getdb();
    final results = await db.query(trackStatisticsTableName);
    
    final Map<String, TrackStatistics> statsMap = {};
    for (final row in results) {
      final stats = TrackStatistics(
        trackId: row['trackId'] as String,
        timesPlayed: row['timesPlayed'] as int,
        timesSkipped: row['timesSkipped'] as int,
        minutesPlayed: row['minutesPlayed'] as double,
        lastPlayedAt: row['lastPlayedAt'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['lastPlayedAt'] as int)
            : null,
        completionCount: row['completionCount'] as int,
      );
      statsMap[stats.trackId] = stats;
    }
    
    return statsMap;
  }

  @override
  Future<void> updateTrackStatistics(TrackStatistics stats) async {
    final db = await _getdb();
    await db.insert(
      trackStatisticsTableName,
      {
        'trackId': stats.trackId,
        'timesPlayed': stats.timesPlayed,
        'timesSkipped': stats.timesSkipped,
        'minutesPlayed': stats.minutesPlayed,
        'lastPlayedAt': stats.lastPlayedAt?.millisecondsSinceEpoch,
        'completionCount': stats.completionCount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> incrementTrackPlayCount(String trackId) async {
    final db = await _getdb();
    
    // Ensure track exists
    await _ensureTrackExists(trackId);
    
    await db.rawUpdate('''
      UPDATE $trackStatisticsTableName
      SET timesPlayed = timesPlayed + 1,
          lastPlayedAt = ?
      WHERE trackId = ?
    ''', [DateTime.now().millisecondsSinceEpoch, trackId]);
  }

  @override
  Future<void> incrementTrackSkipCount(String trackId) async {
    final db = await _getdb();
    
    // Ensure track exists
    await _ensureTrackExists(trackId);
    
    await db.rawUpdate('''
      UPDATE $trackStatisticsTableName
      SET timesSkipped = timesSkipped + 1
      WHERE trackId = ?
    ''', [trackId]);
  }

  @override
  Future<void> incrementTrackCompletionCount(String trackId) async {
    final db = await _getdb();
    
    // Ensure track exists
    await _ensureTrackExists(trackId);
    
    await db.rawUpdate('''
      UPDATE $trackStatisticsTableName
      SET completionCount = completionCount + 1
      WHERE trackId = ?
    ''', [trackId]);
  }

  @override
  Future<void> addTrackPlaybackTime(String trackId, Duration duration) async {
    final db = await _getdb();
    final minutes = duration.inSeconds / 60.0;
    
    // Ensure track exists
    await _ensureTrackExists(trackId);
    
    await db.rawUpdate('''
      UPDATE $trackStatisticsTableName
      SET minutesPlayed = minutesPlayed + ?
      WHERE trackId = ?
    ''', [minutes, trackId]);
  }

  Future<void> _ensureTrackExists(String trackId) async {
    final db = await _getdb();
    await db.insert(
      trackStatisticsTableName,
      {
        'trackId': trackId,
        'timesPlayed': 0,
        'timesSkipped': 0,
        'minutesPlayed': 0.0,
        'lastPlayedAt': null,
        'completionCount': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
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
