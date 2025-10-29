import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:async';

typedef HashFunction = Digest Function(List<int> input);

Future<String> computeFileChecksum(String filePath, HashFunction hashFunction) async {
  try {
    final file = File(filePath);
    final fileStream = file.openRead();
    
    List<int> chunks = [];

    await for (var chunk in fileStream) {
      chunks = [
        ...chunks,
        ...chunk,
      ];
    }

    final hash = hashFunction(chunks);
    return hash.toString();
  } catch (e) {
    // TODO: log this error
    return '';
  }
}
