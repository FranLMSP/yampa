import 'package:crypto/crypto.dart';
import 'package:yampa/core/utils/checksum_utils.dart';

Future<String> generateTrackId(String filePath) async {
  return computeFileChecksum(filePath, sha256.convert);
}
