import 'package:yampa/models/player_controller_state.dart';

abstract class PlayerControllerStateRepository {
  Future<LastPlayerControllerState> getPlayerControllerState();
  Future<void> savePlayerControllerState(
    LastPlayerControllerState playerControllerState,
  );
  Future<void> close();
}
