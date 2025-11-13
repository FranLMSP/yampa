import 'package:yampa/core/repositories/player_controller_state/player_controller_state.dart';
import 'package:yampa/core/repositories/player_controller_state/player_controller_state_sqlite_repository.dart';

PlayerControllerStateRepository getPlayerControllerStateRepository() {
  return PlayerControllerStateSqliteRepository();
}
