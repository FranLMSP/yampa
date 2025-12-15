import 'dart:io';
import 'package:path/path.dart' as p;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yampa/core/utils/file_utils.dart';
import 'package:yampa/widgets/utils.dart';

Future<Database> openSqliteDatabase() async {
  if (isPlatformMobile()) {
    return await openDatabase('app_data.db');
  } else {
    final basePath = await getBasePath();
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
