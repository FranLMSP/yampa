import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> openSqliteDatabase() async {
  if (Platform.isAndroid || Platform.isIOS) {
    return await openDatabase('app_data.db');
  } else {
    // TODO: for Linux, use ~/.local/share/yampa
    // For Windows we could use %AppData%
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String dbPath = p.join(appDocumentsDir.path, "databases", "app_data.db");
    var databaseFactory = databaseFactoryFfi;
    var db = await databaseFactory.openDatabase(dbPath);
    return db;
  }

}
