import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yampa/core/repositories/user_settings_data/factory.dart';
import 'package:yampa/models/user_settings.dart';
import 'package:yampa/providers/initial_load_provider.dart';
import 'package:yampa/providers/loaded_tracks_count_provider.dart';
import 'package:yampa/providers/local_paths_provider.dart';
import 'package:yampa/providers/player_controller_provider.dart';
import 'package:yampa/providers/playlists_provider.dart';
import 'package:yampa/providers/theme_mode_provider.dart';
import 'package:yampa/providers/sort_mode_provider.dart';
import 'package:yampa/providers/utils.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';
import 'package:yampa/widgets/main_browser/main.dart';
import 'package:yampa/widgets/main_page_loader.dart';
import 'package:yampa/widgets/player/big_player.dart';
import 'package:yampa/widgets/utils.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userSettingsRepo = getUserSettingsDataRepository();
  final userSettings = await userSettingsRepo.getUserSettings();
  if (isPlatformDesktop()) {
    await windowManager.ensureInitialized();
    await userSettingsRepo.close();
    Size? windowSize;
    final lastWindowSize = userSettings.lastWindowSize;
    if (lastWindowSize != null) {
      windowSize = Size(lastWindowSize.width, lastWindowSize.height);
    }
    WindowOptions windowOptions = WindowOptions(
      minimumSize: Size(400, 475),
      size: windowSize,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _initialLoadDone = false;

  Future<void> _loadSettings() async {
    if (_initialLoadDone) {
      return;
    }
    final userSettingsRepo = getUserSettingsDataRepository();
    final userSettings = await userSettingsRepo.getUserSettings();
    ref
        .read(themeModeProvider.notifier)
        .setThemeMode(userSettings.themeMode ?? UserThemeMode.system);
    ref
        .read(allTracksSortModeProvider.notifier)
        .setSortMode(userSettings.defaultSortMode);
    await ref
        .read(localizationProvider.notifier)
        .init(userSettings.languageCode);
    await userSettingsRepo.close();
    _initialLoadDone = true;
  }

  @override
  Widget build(BuildContext context) {
    _loadSettings();
    final themeMode = getMaterialThemeFromUserTheme(
      ref.watch(themeModeProvider),
    );
    final _ = ref.watch(localizationProvider); // Rebuild when language changes
    return MaterialApp(
      title: ref.read(localizationProvider.notifier).translate(LocalizationKeys.appTitle),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      locale: Locale(ref.watch(localizationProvider)),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> with WindowListener {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (isPlatformDesktop()) {
      windowManager.addListener(this);
      _initWindow();
    }
  }

  @override
  void dispose() {
    if (isPlatformDesktop()) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  void _initWindow() async {
    await windowManager.setPreventClose(true);
    setState(() {});
  }

  @override
  void onWindowClose() async {
    if (isPlatformDesktop()) {
      final isPreventClose = await windowManager.isPreventClose();
      if (isPreventClose) {
        await windowManager.ensureInitialized();
        final userSettingsRepo = getUserSettingsDataRepository();
        final size = await windowManager.getSize();
        await userSettingsRepo.saveLastWindowSize(
          WindowSize(width: size.width, height: size.height),
        );
        await userSettingsRepo.close();
        await windowManager.destroy();
      }
    }
  }

  void _setTimer() {
    if (_timer != null) {
      return;
    }

    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) async {
      final playerNotifier = ref.watch(playerControllerProvider.notifier);
      final player = playerNotifier.getPlayerController();

      if (player.hasTrackFinishedPlaying()) {
        await playerNotifier.handleNextAutomatically();
      }
      await playerNotifier.updatePlaybackStatistics();
    });
  }

  Future<void> _load(
    bool initialLoadDone,
    InitialLoadNotifier initialLoadNotifier,
    LocalPathsNotifier localPathsNotifier,
    PlaylistNotifier playlistNotifier,
    PlayerControllerNotifier playerControllerNotifier,
    LoadedTracksCountProviderNotifier loadedTracksCountNotifier,
  ) async {
    if (isPlatformMobile()) {
      await Permission.audio.request();
      await Permission.notification.request();
    }
    await doInitialLoad(
      initialLoadDone,
      initialLoadNotifier,
      localPathsNotifier,
      playlistNotifier,
      playerControllerNotifier,
      loadedTracksCountNotifier,
    );
  }

  Widget _buildMainPageLoader() {
    return const MainPageLoader();
  }

  Widget _buildMainContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewMode = getViewMode(constraints);
        if (viewMode == ViewMode.portrait) {
          return Scaffold(
            body: SafeArea(
              child: Center(child: MainBrowser(viewMode: viewMode)),
            ),
          );
        } else {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Row(
                  children: [
                    SizedBox(
                      width: 500,
                      child: MainBrowser(viewMode: viewMode),
                    ),
                    Expanded(child: Center(child: BigPlayer())),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialLoadDone = ref.watch(initialLoadProvider);
    if (!initialLoadDone) {
      final initialLoadNotifier = ref.read(initialLoadProvider.notifier);
      final localPathsNotifier = ref.read(localPathsProvider.notifier);
      final playlistsNotifier = ref.read(playlistsProvider.notifier);
      final playerControllerNotifier = ref.read(
        playerControllerProvider.notifier,
      );
      final loadedTracksCountNotifier = ref.read(
        loadedTracksCountProvider.notifier,
      );
      _load(
        initialLoadDone,
        initialLoadNotifier,
        localPathsNotifier,
        playlistsNotifier,
        playerControllerNotifier,
        loadedTracksCountNotifier,
      );
    }
    _setTimer();
    return initialLoadDone ? _buildMainContent() : _buildMainPageLoader();
  }
}
