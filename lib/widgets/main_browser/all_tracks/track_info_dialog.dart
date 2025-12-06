import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/core/utils/format_utils.dart';
import 'package:yampa/models/track.dart';
import 'package:yampa/providers/statistics_provider.dart';

class TrackInfoDialog extends ConsumerWidget {
  const TrackInfoDialog({
    super.key,
    required this.track,
  });

  final Track track;

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackStatsAsync = ref.watch(trackStatisticsStreamProvider(track.id));

    return AlertDialog(
      title: Text(track.displayName()),
      scrollable: true,
      content: SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Track image
            if (track.imageBytes != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    track.imageBytes!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (track.imageBytes != null) const SizedBox(height: 24),
            
            _buildSection(
              'Metadata',
              [
                _buildInfoRow('Artist', track.artist.isEmpty ? 'Unknown' : track.artist),
                _buildInfoRow('Album', track.album.isEmpty ? 'Unknown' : track.album),
                _buildInfoRow('Genre', track.genre.isEmpty ? 'Unknown' : track.genre),
                _buildInfoRow('Duration', formatDuration(track.duration)),
                _buildInfoRow('Track Number', track.trackNumber.toString()),
                _buildInfoRow('Path', track.path),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Statistics',
              [
                trackStatsAsync.when(
                  data: (stats) {
                    if (stats.timesPlayed == 0) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No statistics yet - play this track to start tracking!',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        _buildInfoRow('Times Played', formatCount(stats.timesPlayed)),
                        _buildInfoRow('Times Skipped', formatCount(stats.timesSkipped)),
                        _buildInfoRow('Times Completed', formatCount(stats.completionCount)),
                        _buildInfoRow(
                          'Total Playback Time',
                          formatDurationLong(Duration(seconds: (stats.minutesPlayed * 60).round())),
                        ),
                        _buildInfoRow('Last Played', formatTimestamp(stats.lastPlayedAt)),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error loading statistics: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
