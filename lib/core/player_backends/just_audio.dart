import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:audiotags/audiotags.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yampa/core/player/player_controller.dart';
import 'package:yampa/core/player/enums.dart' as yampa_loop;
import 'package:yampa/core/player_backends/audio_handler.dart';
import 'package:yampa/core/utils/file_utils.dart';
import 'package:yampa/core/utils/id_utils.dart';
import 'package:yampa/models/path.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/core/repositories/cached_tracks/cached_tracks.dart';
import 'package:yampa/core/repositories/cached_tracks/factory.dart';
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:path/path.dart' as p;
import 'package:yampa/widgets/utils.dart';
import 'interface.dart';

class JustAudioBackend implements PlayerBackend {
  static AudioPlayer? _player;
  static YampaAudioHandler? _audioHandler;

  static YampaAudioHandler? get audioHandler => _audioHandler;

  static void setPlayer(AudioPlayer player) {
    _player = player;
  }

  static void setAudioHandler(YampaAudioHandler handler) {
    _audioHandler = handler;
  }

  Duration? _currentTrackDuration;
  AndroidEqualizer? _equalizer;

  @override
  Future<void> init() async {}

  void _ensurePlayerInitialized() {
    if (_player == null) {
      if (Platform.isAndroid && false) {
        // TODO: this doesn't seem to work yet
        _equalizer = AndroidEqualizer();
        _player = AudioPlayer(
          audioPipeline: AudioPipeline(androidAudioEffects: [_equalizer!]),
        );
      } else {
        _player = AudioPlayer();
      }
      _audioHandler = YampaAudioHandler(_player!);
    }
  }

  Future<Uri?> _saveAlbumArtToTempFile(Uint8List? imageBytes) async {
    if (imageBytes == null) return null;

    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/current_album_art.png');
      await tempFile.writeAsBytes(imageBytes);
      return Uri.file(tempFile.path);
    } catch (e) {
      log('Error saving album art to temp file', error: e);
      return null;
    }
  }

  @override
  Future<List<Track>> fetchTracks(
    List<GenericPath> paths,
    PlayerControllerNotifier playerControllerNotifier,
    LoadedTracksCountProviderNotifier loadedTracksCountNotifier, {
    List<Track>? cachedTracks,
  }) async {
    loadedTracksCountNotifier.reset();
    final Map<String, Track> foundTracks = HashMap();

    final Map<String, Track> cachedTracksMap = {
      if (cachedTracks != null)
        for (final track in cachedTracks) track.path: track,
    };
    final cachedTracksRepository = getCachedTracksRepository();

    final allEffectivePaths = await _gatherEffectivePaths(paths);

    loadedTracksCountNotifier.setTotalTracks(allEffectivePaths.length);

    for (final path in allEffectivePaths) {
      final cachedTrack = cachedTracksMap[path.filename];
      bool useCache = false;

      if (cachedTrack != null) {
        final file = File(path.filename!);
        if (await file.exists()) {
          final lastModified = await file.lastModified();
          if (cachedTrack.lastModified != null &&
              cachedTrack.lastModified!.isAtSameMomentAs(lastModified)) {
            useCache = true;
          }
        }
      }

      if (useCache) {
        foundTracks[cachedTrack!.id] = cachedTrack;
        loadedTracksCountNotifier.incrementLoadedTrack();
      } else {
        final track = await _getTrackMetadataFromGenericPath(path.filename!);
        if (track != null) {
          playerControllerNotifier.addTracks([track]);
          await cachedTracksRepository.addOrUpdate(track);
          foundTracks[track.id] = track; // Add newly found track to the map
        }
        loadedTracksCountNotifier.incrementLoadedTrack();
      }
    }

    await _removeStaleCachedTracks(
      cachedTracks,
      foundTracks,
      paths,
      cachedTracksRepository,
      playerControllerNotifier,
    );

    await cachedTracksRepository.close();
    loadedTracksCountNotifier.reset();
    return foundTracks.values.toList();
  }

  Future<List<GenericPath>> _gatherEffectivePaths(
    List<GenericPath> paths,
  ) async {
    final List<GenericPath> filePaths = [];
    filePaths.addAll(paths.where((e) => e.filename != null));

    for (final path in paths.where(
      (e) => e.filename == null && e.folder != null,
    )) {
      final dir = Directory(path.folder!);
      try {
        await for (final entity in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File && isValidMusicPath(entity.path)) {
            filePaths.add(
              GenericPath(
                id: path.id,
                folder: path.folder,
                filename: entity.path,
              ),
            );
          }
        }
      } catch (e) {
        log("Couldn't read directory", error: e);
      }
    }

    return filePaths;
  }

  Future<void> _removeStaleCachedTracks(
    List<Track>? cachedTracks,
    Map<String, Track> foundTracks,
    List<GenericPath> rootPaths,
    CachedTracksRepository cachedTracksRepository,
    PlayerControllerNotifier playerControllerNotifier,
  ) async {
    if (cachedTracks == null) return;

    final List<String> tracksToRemove = [];

    for (final cachedTrack in cachedTracks) {
      if (!foundTracks.containsKey(cachedTrack.id)) {
        bool belongsToScannedPaths = false;
        for (final rootPath in rootPaths) {
          if (rootPath.folder != null) {
            if (p.isWithin(rootPath.folder!, cachedTrack.path)) {
              belongsToScannedPaths = true;
              break;
            }
          } else if (rootPath.filename != null) {
            if (cachedTrack.path == rootPath.filename) {
              belongsToScannedPaths = true;
              break;
            }
          }
        }

        if (belongsToScannedPaths) {
          tracksToRemove.add(cachedTrack.id);
          await cachedTracksRepository.remove(cachedTrack.path);
        }
      }
    }

    if (tracksToRemove.isNotEmpty) {
      playerControllerNotifier.removeTracks(tracksToRemove);
    }
  }

  Future<Track?> _getTrackMetadataFromGenericPath(String path) async {
    try {
      final file = File(path);
      Tag? tag = await AudioTags.read(path);
      final lastModified = await file.lastModified();
      return Track(
        id: await generateTrackId(path),
        title: tag?.title ?? "",
        artist: tag?.trackArtist ?? "",
        album: tag?.album ?? "",
        genre: tag?.genre ?? "",
        trackNumber: tag?.trackNumber ?? 0,
        path: path,
        duration: tag?.duration != null
            ? Duration(seconds: tag!.duration!)
            : Duration.zero,
        imageBytes: tag != null && tag.pictures.isNotEmpty
            ? tag.pictures.first.bytes
            : null,
        lastModified: lastModified,
      );
    } catch (e) {
      log('Error reading metadata', error: e);
    }
    return null;
  }

  @override
  Future<Duration> setTrack(Track track) async {
    _ensurePlayerInitialized();
    // TODO: maybe detect here if the path is an URL or not, and call setUrl if that's the case
    Duration? duration;
    try {
      final audioSource = AudioSource.uri(Uri.file(track.path));
      duration = await _player!.setAudioSource(audioSource);

      final artUri = await _saveAlbumArtToTempFile(track.imageBytes);
      await _audioHandler?.updateMediaItem(
        MediaItem(
          id: track.id,
          title: track.displayTitle(),
          artist: track.artist,
          album: track.album,
          duration: duration,
          artUri: artUri,
        ),
      );
    } catch (e) {
      log("Unable to set audio source", error: e);
    }
    _currentTrackDuration = duration;
    return duration ?? Duration.zero;
  }

  @override
  Duration getCurrentTrackDuration() {
    return _currentTrackDuration ?? Duration.zero;
  }

  @override
  Future<void> play() async {
    _ensurePlayerInitialized();
    if (!_player!.playing) {
      // Do not await play() because just_audio's play() future completes when playback completes (song ends).
      // We want to return immediately to update the UI.
      _player!.play();
    }
  }

  @override
  Future<void> pause() async {
    _ensurePlayerInitialized();
    if (_player!.playing) {
      await _player!.pause();
    }
  }

  @override
  Future<void> stop() async {
    _ensurePlayerInitialized();
    if (_player!.playing) {
      await _player!.stop();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    _ensurePlayerInitialized();
    try {
      await _player!.seek(position);
    } catch (e) {
      log("Error seeking", error: e);
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    _ensurePlayerInitialized();
    await _player!.setSpeed(speed);
  }

  @override
  Future<void> setVolume(double volume) async {
    _ensurePlayerInitialized();
    await _player!.setVolume(volume);
  }

  @override
  Future<void> setEqualizerGains(List<double> gains) async {
    _ensurePlayerInitialized();
    if (_equalizer != null) {
      final bands = (await _equalizer!.parameters).bands;
      for (var i = 0; i < bands.length && i < gains.length; i++) {
        await bands[i].setGain(gains[i]);
      }
    }
  }

  @override
  Future<void> setLoopMode(yampa_loop.LoopMode mode) async {
    _ensurePlayerInitialized();
    final justAudioLoopMode = {
      yampa_loop.LoopMode.singleTrack: LoopMode.one,
      yampa_loop.LoopMode.infinite: LoopMode.all,
      yampa_loop.LoopMode.startToEnd: LoopMode.off,
      yampa_loop.LoopMode.none: LoopMode.off,
    }[mode];

    if (justAudioLoopMode != null) {
      await _player!.setLoopMode(justAudioLoopMode);
    }
  }

  @override
  Stream<void> get onTrackFinished {
    _ensurePlayerInitialized();
    return _player!.processingStateStream
        .where((state) => state == ProcessingState.completed)
        .map((_) => null);
  }

  @override
  Future<Duration> getCurrentPosition() async {
    _ensurePlayerInitialized();
    return _player!.position;
  }

  @override
  bool hasTrackFinishedPlaying() {
    _ensurePlayerInitialized();
    return _player!.processingState == ProcessingState.completed;
  }

  @override
  Future<Track> updateTrackMetadata(Track track) async {
    final hasStorageAccess = isPlatformMobile()
        ? await Permission.storage.isGranted
        : true;
    if (!hasStorageAccess) {
      await Permission.storage.request();
    }

    // Stop playback if the track being edited is the currently active one
    // to avoid file locking issues on some platforms.
    bool wasPlaying = false;
    Duration? position;
    if (PlayerController.instance.currentTrackId == track.id) {
      wasPlaying = _player?.playing ?? false;
      position = _player?.position;
      if (wasPlaying) {
        await stop();
      }
    }

    Tag? existingTag = await AudioTags.read(track.path);

    Tag tag = Tag(
      title: track.title,
      trackArtist: track.artist,
      album: track.album,
      albumArtist: track.artist,
      genre: track.genre,
      year: existingTag?.year,
      trackNumber: track.trackNumber,
      trackTotal: existingTag?.trackTotal,
      discNumber: existingTag?.discNumber,
      discTotal: existingTag?.discTotal,
      pictures: track.imageBytes != null
          ? [
              Picture(
                bytes: Uint8List.fromList(track.imageBytes!),
                mimeType: null,
                pictureType: PictureType.other,
              ),
            ]
          : [],
    );

    await AudioTags.write(track.path, tag);

    final updatedTrack = await _getTrackMetadataFromGenericPath(track.path);

    if (wasPlaying) {
      await setTrack(updatedTrack!);
      if (position != null) {
        await seek(position);
      }
      await play();
    }

    return updatedTrack!;
  }
}
