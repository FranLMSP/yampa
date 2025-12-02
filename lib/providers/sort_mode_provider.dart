import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';

final allTracksSortModeProvider = NotifierProvider<AllTracksSortModeNotifier, SortMode>(
  () => AllTracksSortModeNotifier(),
);

class AllTracksSortModeNotifier extends Notifier<SortMode> {
  @override
  SortMode build() {
    return SortMode.titleAtoZ;
  }

  void setSortMode(SortMode mode) {
    state = mode;
  }
}
