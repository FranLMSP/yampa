import 'dart:developer';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:ulid/ulid.dart';
import 'package:image/image.dart' as img;

const String kUserImagesFolder = "user_images";

String extractFilenameFromFullPath(String string) {
  if (string.isEmpty) return "";
  // Handles both Unix (/) and Windows (\) separators
  final separators = ['/', '\\'];
  for (var sep in separators) {
    if (string.contains(sep)) {
      return string.split(sep).last;
    }
  }
  return string; // If no separator, return the original string
}

String getParentFolder(String folder) {
  if (folder.isEmpty) return "";
  // Normalize separators
  final normalized = folder.replaceAll('\\', '/');
  // Remove trailing slash if present (except for root '/')
  final trimmed = normalized.endsWith('/') && normalized.length > 1
      ? normalized.substring(0, normalized.length - 1)
      : normalized;
  final lastSlash = trimmed.lastIndexOf('/');
  if (lastSlash <= 0) return ""; // No parent or root
  return trimmed.substring(0, lastSlash);
}

bool isValidMusicPath(String path) {
  // TODO: maybe check for mimetype here as well?

  return (path.endsWith(".mp4") ||
      path.endsWith(".m4a") ||
      path.endsWith(".mp3") ||
      path.endsWith(".ogg") ||
      path.endsWith(".ogg") ||
      path.endsWith(".opus") ||
      path.endsWith(".wav") ||
      path.endsWith(".flac"));
}

bool isValidImagePath(String path) {
  // TODO: maybe check for mimetype here as well?

  return (path.endsWith(".gif") ||
      path.endsWith(".jpg") ||
      path.endsWith(".jpeg") ||
      path.endsWith(".webp") ||
      path.endsWith(".png") && io.File(path).existsSync());
}

Future<String> getBasePath() async {
  // Use platform-appropriate data folder:
  // - Linux: $XDG_DATA_HOME/yampa or ~/.local/share/yampa
  // - Windows: %APPDATA%\yampa
  // - macOS: ~/Library/Application Support/yampa
  // - Fallback: application documents directory
  String basePath;
  if (io.Platform.isLinux) {
    final xdg = io.Platform.environment['XDG_DATA_HOME'];
    basePath = (xdg != null && xdg.isNotEmpty)
        ? p.join(xdg, 'yampa')
        : p.join(
            io.Platform.environment['HOME'] ?? '.',
            '.local',
            'share',
            'yampa',
          );
  } else if (io.Platform.isWindows) {
    final appdata =
        io.Platform.environment['APPDATA'] ??
        p.join(
          io.Platform.environment['USERPROFILE'] ?? '.',
          'AppData',
          'Roaming',
        );
    basePath = p.join(appdata, 'yampa');
  } else if (io.Platform.isMacOS) {
    basePath = p.join(
      io.Platform.environment['HOME'] ?? '.',
      'Library',
      'Application Support',
      'yampa',
    );
  } else {
    final io.Directory appDocumentsDir =
        await getApplicationDocumentsDirectory();
    basePath = p.join(appDocumentsDir.path, 'yampa');
  }
  return basePath;
}

Future<String?> copyFileToLocal(String srcPath, String targetFolder) async {
  try {
    final srcFile = io.File(srcPath);
    if (!await srcFile.exists()) return null;

    final basePath = await getBasePath();
    final imagesDirPath = p.join(basePath, targetFolder);
    final imagesDir = io.Directory(imagesDirPath);
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final extension = p.extension(srcPath);
    final destFilename = '${Ulid().toString()}$extension';
    final destPath = p.join(imagesDirPath, destFilename);

    final copied = await srcFile.copy(destPath);
    return copied.path;
  } catch (e) {
    log("Couldn't copy file", error: e);
    return null;
  }
}

Future<String?> copyImageToLocal(String srcPath) async {
  return copyFileToLocal(srcPath, kUserImagesFolder);
}

Future<List<String>> listUserImages() async {
  try {
    final basePath = await getBasePath();
    final imagesDirPath = p.join(basePath, kUserImagesFolder);
    final imagesDir = io.Directory(imagesDirPath);
    if (!await imagesDir.exists()) {
      return [];
    }
    return await imagesDir
        .list()
        .where((entity) => entity is io.File)
        .map((entity) => entity.path)
        .toList();
  } catch (e) {
    log("Couldn't list user images", error: e);
    return [];
  }
}

Future<void> deleteFile(String path) async {
  try {
    final file = io.File(path);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    log("Couldn't delete file", error: e);
  }
}

Future<Uint8List> convertToJpeg(Uint8List bytes) async {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw Exception("Failed to decode image");
  }
  return Uint8List.fromList(img.encodeJpg(decoded, quality: 90));
}

Uint8List? extractMp3Image(Uint8List mp3Data) {
  // MP3 must start with ID3 tag to contain APIC image
  if (mp3Data.length < 10 ||
      mp3Data[0] != 0x49 || // 'I'
      mp3Data[1] != 0x44 || // 'D'
      mp3Data[2] != 0x33    // '3'
  ) {
    return null;
  }

  // Tag header size is synchsafe
  int tagSize = (mp3Data[6] << 21) |
                (mp3Data[7] << 14) |
                (mp3Data[8] << 7)  |
                 mp3Data[9];

  int offset = 10;
  int end = offset + tagSize;

  while (offset + 10 < end) {
    // Read frame header
    String frameId = String.fromCharCodes(mp3Data.sublist(offset, offset + 4));
    int frameSize = (mp3Data[offset + 4] << 24) |
                    (mp3Data[offset + 5] << 16) |
                    (mp3Data[offset + 6] << 8)  |
                     mp3Data[offset + 7];

    // Stop if invalid
    if (frameSize <= 0 || offset + 10 + frameSize > mp3Data.length) break;

    // Look for APIC frame
    if (frameId == "APIC") {
      int pos = offset + 10;

      // Text encoding byte
      pos += 1;

      // MIME type until null byte
      int mimeEnd = mp3Data.indexOf(0, pos);
      if (mimeEnd == -1) return null;
      pos = mimeEnd + 1;

      // Skip picture type
      pos += 1;

      // Description (null-terminated)
      int descEnd = mp3Data.indexOf(0, pos);
      if (descEnd == -1) return null;
      pos = descEnd + 1;

      // Remaining bytes = image
      return Uint8List.fromList(
        mp3Data.sublist(pos, offset + 10 + frameSize),
      );
    }

    // Move to next frame
    offset += 10 + frameSize;
  }

  return null;
}
