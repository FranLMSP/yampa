import 'package:yampa/core/utils/checksum_utils.dart';

Future<String> generateTrackId(String filePath) async {
  return await computeFastFileFingerprint(filePath);
}
