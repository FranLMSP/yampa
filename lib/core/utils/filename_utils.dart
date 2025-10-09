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
