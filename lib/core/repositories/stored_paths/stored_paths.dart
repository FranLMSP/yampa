import 'package:yampa/models/path.dart';

abstract class StoredPaths {
  Future<List<GenericPath>> getStoredPaths();
  Future<String> addPath(GenericPath path);
  Future<void> removePath(GenericPath path);
  Future<void> close();
}
