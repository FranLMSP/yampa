String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

double getPercentage(double a, double b) {
  if (b == 0 || b.isNaN) return 0.0;
  final result = a / b;
  if (result.isNaN) return 0.0;
  return (result).clamp(0.0, 1.0);
}
