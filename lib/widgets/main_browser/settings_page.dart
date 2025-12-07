import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/format_utils.dart';
import 'package:yampa/providers/statistics_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _buildSettingsOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingsOption(
            context: context,
            title: 'Statistics',
            subtitle: 'View player and track statistics',
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
        ],
      ),
    );
  }
}

class PlayerStatisticsPage extends ConsumerWidget {
  const PlayerStatisticsPage({super.key});

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStatsAsync = ref.watch(playerStatisticsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Player Statistics')),
      body: playerStatsAsync.when(
        data: (stats) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildStatCard(
                'Total Playback Time',
                formatDurationLong(
                  Duration(seconds: (stats.totalMinutesPlayed * 60).round()),
                ),
                Icons.access_time,
              ),
              _buildStatCard(
                'Total Tracks Played',
                formatCount(stats.totalTracksPlayed),
                Icons.music_note,
              ),
              _buildStatCard(
                'Unique Tracks Played',
                formatCount(stats.totalUniqueTracksPlayed),
                Icons.library_music,
              ),
              _buildStatCard(
                'Total Uptime',
                formatDurationLong(stats.uptime),
                Icons.timer,
              ),
              _buildStatCard(
                'Times Started',
                formatCount(stats.timesStarted),
                Icons.play_circle_outline,
              ),
              _buildStatCard(
                'Total Skips',
                formatCount(stats.totalSkips),
                Icons.skip_next,
              ),
              _buildStatCard(
                'Last Played',
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
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.grey),
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
