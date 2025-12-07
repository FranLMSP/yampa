import 'package:intl/intl.dart';

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

String formatDurationLong(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    if (minutes > 0) {
      return "$hours hour${hours != 1 ? 's' : ''} $minutes minute${minutes != 1 ? 's' : ''}";
    }
    return "$hours hour${hours != 1 ? 's' : ''}";
  } else if (minutes > 0) {
    if (seconds > 0) {
      return "$minutes minute${minutes != 1 ? 's' : ''} $seconds second${seconds != 1 ? 's' : ''}";
    }
    return "$minutes minute${minutes != 1 ? 's' : ''}";
  } else {
    return "$seconds second${seconds != 1 ? 's' : ''}";
  }
}

String formatTimestamp(DateTime? timestamp) {
  if (timestamp == null) {
    return "Never";
  }
  final formatter = DateFormat('MMM dd, yyyy \'at\' HH:mm');
  return formatter.format(timestamp);
}

String formatCount(int count) {
  final formatter = NumberFormat('#,###');
  return formatter.format(count);
}

double getPercentage(double a, double b) {
  if (b == 0 || b.isNaN) return 0.0;
  final result = a / b;
  if (result.isNaN) return 0.0;
  return (result).clamp(0.0, 1.0);
}
