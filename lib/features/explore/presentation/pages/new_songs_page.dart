import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/presentation/controllers/player_notifier.dart';
import '../../../player/domain/entities/track.dart';
import '../controllers/new_tracks_notifier.dart';
import '../../../player/presentation/pages/player_page.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';

class NewSongsPage extends ConsumerWidget {
  const NewSongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newTracksAsync = ref.watch(newTracksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text('Bài hát mới nhất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: newTracksAsync.when(
        data: (tracks) {
          if (tracks.isEmpty) {
            return const Center(
              child: Text('Không có bài hát mới nào.', style: TextStyle(color: Colors.white70)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return _buildSongTile(ref, track);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
        error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildSongTile(WidgetRef ref, Track track) {
    final hasNetworkImage = track.coverUrl != null && track.coverUrl!.isNotEmpty && track.coverUrl!.startsWith('http');

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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  track.artistIds.isNotEmpty ? track.artistIds.first : 'Unknown Artist',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.headset_rounded, size: 12, color: Colors.white.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Text(
                FormatUtils.formatListeners(track.listeners),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
              ),
            ],
          ),
          trailing: const Icon(Icons.play_arrow_rounded, color: Colors.cyanAccent),
          onTap: () {
            ref.read(playerNotifierProvider.notifier).playTrack(track);
          },
        ),
      ),
    );
  }
}
