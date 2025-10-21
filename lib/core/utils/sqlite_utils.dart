import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> openSqliteDatabase() async {
  if (Platform.isAndroid || Platform.isIOS) {
    return await openDatabase('app_data.db');
  } else {
    // Use platform-appropriate data folder:
    // - Linux: $XDG_DATA_HOME/yampa or ~/.local/share/yampa
    // - Windows: %APPDATA%\yampa
    // - macOS: ~/Library/Application Support/yampa
    // - Fallback: application documents directory
    String basePath;
    if (Platform.isLinux) {
      final xdg = Platform.environment['XDG_DATA_HOME'];
      basePath = (xdg != null && xdg.isNotEmpty)
        ? p.join(xdg, 'yampa')
        : p.join(Platform.environment['HOME'] ?? '.', '.local', 'share', 'yampa');
    } else if (Platform.isWindows) {
      final appdata = Platform.environment['APPDATA'] ??
        p.join(Platform.environment['USERPROFILE'] ?? '.', 'AppData', 'Roaming');
      basePath = p.join(appdata, 'yampa');
    } else if (Platform.isMacOS) {
      basePath = p.join(Platform.environment['HOME'] ?? '.', 'Library', 'Application Support', 'yampa');
    } else {
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      basePath = p.join(appDocumentsDir.path, 'yampa');
    }

    final Directory dbDir = Directory(p.join(basePath, 'databases'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    final String dbPath = p.join(dbDir.path, "app_data.db");
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase(dbPath);
    return db;
  }

}
