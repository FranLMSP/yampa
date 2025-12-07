import 'package:yampa/models/track.dart';

String stringifyTrackProperties(Track track) {
  return "${track.displayName()}${track.album}${track.artist}${track.genre}";
}

bool checkSearchMatch(String searchText, String targetText) {
  return targetText.trim().toLowerCase().contains(
    searchText.trim().toLowerCase(),
  );
}
