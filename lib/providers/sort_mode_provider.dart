import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/player/enums.dart';
import 'package:yampa/core/repositories/user_settings_data/factory.dart';

final allTracksSortModeProvider =
    NotifierProvider<AllTracksSortModeNotifier, SortMode>(
      () => AllTracksSortModeNotifier(),
    );

class AllTracksSortModeNotifier extends Notifier<SortMode> {
  @override
  SortMode build() {
    return SortMode.titleAtoZ;
  }

  void setSortMode(SortMode mode) async {
    state = mode;
    final repo = getUserSettingsDataRepository();
    await repo.saveDefaultSortMode(mode);
    await repo.close();
  }
}
