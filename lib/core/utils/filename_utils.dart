import 'dart:io' as io;

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

  return (
    path.endsWith(".mp4")  ||
    path.endsWith(".m4a")  ||
    path.endsWith(".mp3")  ||
    path.endsWith(".ogg")  ||
    path.endsWith(".ogg")  ||
    path.endsWith(".opus") ||
    path.endsWith(".wav")  ||
    path.endsWith(".flac")
  );
}

bool isValidImagePath(String path) {
  // TODO: maybe check for mimetype here as well?

  return (
    path.endsWith(".gif") ||
    path.endsWith(".jpg") ||
    path.endsWith(".jpeg") ||
    path.endsWith(".webp") ||
    path.endsWith(".png") &&
    io.File(path).existsSync()
  );
}
