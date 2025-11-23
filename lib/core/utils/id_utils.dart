// import 'package:crypto/crypto.dart';
// import 'package:flutter/foundation.dart';
import 'package:yampa/core/utils/checksum_utils.dart';

Future<String> generateTrackId(String filePath) async {
  // return await compute(computeFileChecksum, filePath);
  // return await computeFastFileFingerprint(filePath);
  return computeFastFileFingerprintV2(filePath);
}
