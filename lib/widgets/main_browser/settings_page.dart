import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/repositories/user_settings_data/factory.dart';
import 'package:yampa/core/utils/format_utils.dart';
import 'package:yampa/models/user_settings.dart';
import 'package:yampa/providers/statistics_provider.dart';
import 'package:yampa/providers/theme_mode_provider.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Widget _buildSettingsOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 32),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              ref
                  .read(localizationProvider.notifier)
                  .translate(LocalizationKeys.settings),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          _buildSettingsOption(
            context: context,
            title: ref
                .read(localizationProvider.notifier)
                .translate(LocalizationKeys.statistics),
            subtitle: ref
                .read(localizationProvider.notifier)
                .translate(LocalizationKeys.statisticsSubtitle),
            icon: Icons.bar_chart,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlayerStatisticsPage(),
                ),
              );
            },
          ),
          _buildSettingsOption(
            context: context,
            title: ref
                .read(localizationProvider.notifier)
                .translate(LocalizationKeys.theme),
            subtitle: ref
                .read(localizationProvider.notifier)
                .translate(LocalizationKeys.themeSubtitle),
            icon: Icons.brush,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserThemePage()),
              );
            },
          ),
          _buildSettingsOption(
            context: context,
            title: ref
                .read(localizationProvider.notifier)
                .translate(LocalizationKeys.language),
            subtitle: ref
                .read(localizationProvider.notifier)
                .translate(LocalizationKeys.languageSubtitle),
            icon: Icons.language,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSelectionPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PlayerStatisticsPage extends ConsumerWidget {
  const PlayerStatisticsPage({super.key});

  Widget _buildStatCard(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStatsAsync = ref.watch(playerStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ref
              .read(localizationProvider.notifier)
              .translate(LocalizationKeys.playerStatistics),
        ),
      ),
      body: playerStatsAsync.when(
        data: (stats) {
          return ListView(
            children: [
              _buildStatCard(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.totalPlaybackTime),
                formatDurationLong(
                  Duration(seconds: (stats.totalMinutesPlayed * 60).round()),
                ),
                Icons.access_time,
              ),
              _buildStatCard(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.totalTracksPlayed),
                formatCount(stats.totalTracksPlayed),
                Icons.music_note,
              ),
              _buildStatCard(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.uniqueTracksPlayed),
                formatCount(stats.totalUniqueTracksPlayed),
                Icons.library_music,
              ),
              _buildStatCard(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.totalUptime),
                formatDurationLong(stats.uptime),
                Icons.timer,
              ),
              _buildStatCard(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.timesStarted),
                formatCount(stats.timesStarted),
                Icons.play_circle_outline,
              ),
              _buildStatCard(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.totalSkips),
                formatCount(stats.totalSkips),
                Icons.skip_next,
              ),
              _buildStatCard(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.lastPlayed),
                formatTimestamp(stats.lastPlayedAt),
                Icons.schedule,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  ref
                      .read(localizationProvider.notifier)
                      .translate(LocalizationKeys.errorLoadingStatistics),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserThemePage extends ConsumerStatefulWidget {
  const UserThemePage({super.key});

  @override
  ConsumerState<UserThemePage> createState() => _UserThemePageState();
}

class _UserThemePageState extends ConsumerState<UserThemePage> {
  bool _initialLoadDone = false;
  UserThemeMode _userThemeMode = UserThemeMode.system;

  Future<void> _loadUserTheme() async {
    if (_initialLoadDone) {
      return;
    }
    final userSettingsRepo = getUserSettingsDataRepository();
    final theme = await userSettingsRepo.getUserTheme();
    setState(() {
      _userThemeMode = theme;
    });
    _initialLoadDone = true;
  }

  Future<void> _setTheme(UserThemeMode? pickedTheme) async {
    final theme = pickedTheme ?? UserThemeMode.system;
    ref.read(themeModeProvider.notifier).setThemeMode(theme);
    final userSettingsRepo = getUserSettingsDataRepository();
    userSettingsRepo.saveUserTheme(theme);
    setState(() {
      _userThemeMode = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadUserTheme();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ref
              .read(localizationProvider.notifier)
              .translate(LocalizationKeys.theme),
        ),
      ),
      body: RadioGroup(
        groupValue: _userThemeMode,
        onChanged: _setTheme,
        child: Column(
          children: [
            ListTile(
              leading: Radio(value: UserThemeMode.system),
              title: Text(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.system),
              ),
              onTap: () => _setTheme(UserThemeMode.system),
            ),
            ListTile(
              leading: Radio(value: UserThemeMode.light),
              title: Text(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.light),
              ),
              onTap: () => _setTheme(UserThemeMode.light),
            ),
            ListTile(
              leading: Radio(value: UserThemeMode.dark),
              title: Text(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.dark),
              ),
              onTap: () => _setTheme(UserThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageSelectionPage extends ConsumerWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(localizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ref
              .read(localizationProvider.notifier)
              .translate(LocalizationKeys.selectLanguage),
        ),
      ),
      body: RadioGroup<String>(
        groupValue: currentLanguage,
        onChanged: (value) =>
            ref.read(localizationProvider.notifier).setLanguage(value!),
        child: ListView(
          children: [
            ListTile(
              leading: const Radio<String>(value: LocalizationKeys.en),
              title: Text(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.en),
              ),
              onTap: () => ref
                  .read(localizationProvider.notifier)
                  .setLanguage(LocalizationKeys.en),
            ),
            ListTile(
              leading: const Radio<String>(value: LocalizationKeys.es),
              title: Text(
                ref
                    .read(localizationProvider.notifier)
                    .translate(LocalizationKeys.es),
              ),
              onTap: () => ref
                  .read(localizationProvider.notifier)
                  .setLanguage(LocalizationKeys.es),
            ),
          ],
        ),
      ),
    );
  }
}
