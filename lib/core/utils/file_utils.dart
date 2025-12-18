import 'dart:developer';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:convert';
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

Future<String?> saveBase64Image(String base64String) async {
  try {
    // TODO: this block of code seems duplicated so we have to find a way to reuse some of the logic here
    final bytes = base64.decode(base64String);
    final basePath = await getBasePath();
    final imagesDirPath = p.join(basePath, kUserImagesFolder);
    final imagesDir = io.Directory(imagesDirPath);
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final destFilename = '${Ulid().toString()}.jpg';
    final destPath = p.join(imagesDirPath, destFilename);

    final file = io.File(destPath);
    await file.writeAsBytes(bytes);
    return destPath;
  } catch (e) {
    log("Couldn't save base64 image", error: e);
    return null;
  }
}

Future<String?> fileToBase64(String path) async {
  try {
    final file = io.File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    return base64.encode(bytes);
  } catch (e) {
    log("Couldn't convert file to base64", error: e);
    return null;
  }
}
