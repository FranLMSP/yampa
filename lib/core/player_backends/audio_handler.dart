import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'package:yampa/core/player/player_controller.dart';

class YampaAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player;

  YampaAudioHandler(this._player) {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() => PlayerController.instance.play();

  @override
  Future<void> pause() => PlayerController.instance.pause();

  @override
  Future<void> seek(Duration position) => PlayerController.instance.seek(position);

  @override
  Future<void> stop() => PlayerController.instance.stop();

  @override
  Future<void> skipToNext() async {
    await PlayerController.instance.next(true);
  }

  @override
  Future<void> skipToPrevious() async {
    await PlayerController.instance.prev();
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    this.mediaItem.add(mediaItem);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
