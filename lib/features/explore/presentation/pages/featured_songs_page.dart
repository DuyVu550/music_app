import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/presentation/controllers/player_notifier.dart';
import '../../../player/domain/entities/track.dart';
import '../controllers/featured_tracks_notifier.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../../player/presentation/widgets/song_options_bottom_sheet.dart';

class FeaturedSongsPage extends ConsumerWidget {
  const FeaturedSongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredTracksAsync = ref.watch(featuredTracksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text(
          'Bài hát nổi bật',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: featuredTracksAsync.when(
        data: (tracks) {
          if (tracks.isEmpty) {
            return const Center(
              child: Text(
                'Không có bài hát nổi bật nào.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return _buildSongTile(context, ref, track);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
        error: (err, stack) => Center(
          child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildSongTile(BuildContext context, WidgetRef ref, Track track) {
    final hasNetworkImage =
        track.coverUrl != null &&
        track.coverUrl!.isNotEmpty &&
        (track.coverUrl!.startsWith('http') || track.coverUrl!.startsWith('data:'));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hasNetworkImage
                ? Image.network(
                    track.coverUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/album_placeholder.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/album_placeholder.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
          ),
          title: Text(
            track.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  track.artistIds.isNotEmpty
                      ? track.artistIds.first
                      : 'Unknown Artist',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.headset_rounded,
                size: 12,
                color: Colors.white.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 4),
              Text(
                FormatUtils.formatListeners(track.listeners),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FavoriteButton(trackId: track.id, size: 20),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SongOptionsBottomSheet(track: track),
                  );
                },
              ),
            ],
          ),
          onTap: () {
            ref.read(playerNotifierProvider.notifier).playTrack(track);
          },
        ),
      ),
    );
  }
}
