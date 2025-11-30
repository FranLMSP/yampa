import 'dart:developer';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:convert';

typedef HashFunction = Digest Function(List<int> input);

Future<String> computeFileChecksum(String filePath, {HashFunction? hashFunction}) async {
  final hf = hashFunction ?? md5.convert;
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

    final hash = hf(chunks);
    return hash.toString();
  } catch (e) {
    log('Error computing file checksum', error: e);
    return '';
  }
}

Future<String> computeFastFileFingerprint(String filePath, {int headBytes = 4096, int tailBytes = 4096}) async {
  // TODO: this function currently doesn't work. For some reason the whole app crashes when loading a certain amount of tracks.
  try {
    final file = File(filePath);
    if (!await file.exists()) return '';

    final length = await file.length();
    final stat = await file.stat();

    final raf = await file.open();
    final int headSize = length < headBytes ? length.toInt() : headBytes;
    final head = headSize > 0 ? await raf.read(headSize) : <int>[];

    List<int> tail = <int>[];
    if (length > headBytes && tailBytes > 0) {
      final int tailSize = length < tailBytes ? length.toInt() : tailBytes;
      await raf.setPosition(length - tailSize);
      tail = await raf.read(tailSize);
    }
    await raf.close();

    final meta = utf8.encode('$length:${stat.modified.millisecondsSinceEpoch}');
    final combined = [
      ...head,
      ...tail,
      ...meta,
    ];
    final hash = sha1.convert(combined);
    return hash.toString();
  } catch (e) {
    log('Error computing fast file fingerprint', error: e);
    return '';
  }
}

Future<String> computeFastFileFingerprintV2(String path) async {
  final file = File(path);
  final stat = await file.stat();
  final stream = file.openRead();

  final partialHash = await md5.bind(stream).last;

  final raw = '${stat.size}-${partialHash.toString()}';
  return sha1.convert(utf8.encode(raw)).toString();
}
