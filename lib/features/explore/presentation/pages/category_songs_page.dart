import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/presentation/controllers/player_notifier.dart';
import '../../../player/domain/entities/track.dart';
import '../../domain/entities/category.dart';
import '../controllers/categories_notifier.dart';
import '../../../player/presentation/pages/player_page.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';

class CategorySongsPage extends ConsumerWidget {
  final Category category;

  const CategorySongsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(categoryTracksProvider(category.id));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: Text(category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: tracksAsync.when(
        data: (tracks) {
          if (tracks.isEmpty) {
            return const Center(
              child: Text('Không có bài hát nào trong thể loại này.', style: TextStyle(color: Colors.white70)),
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
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
        error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red))),
      ),
      bottomSheet: _buildBottomPlayer(context, ref),
    );
  }

  Widget _buildSongTile(BuildContext context, WidgetRef ref, Track track) {
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
                    errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/album_placeholder.png', width: 50, height: 50, fit: BoxFit.cover),
                  )
                : Image.asset('assets/images/album_placeholder.png', width: 50, height: 50, fit: BoxFit.cover),
          ),
          title: Text(track.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
              ),
            ],
          ),
          trailing: FavoriteButton(trackId: track.id),
          onTap: () {
            ref.read(playerNotifierProvider.notifier).playTrack(track);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlayerPage()),
            );
          },
        ),
      ),
    );
  }

  Widget? _buildBottomPlayer(BuildContext context, WidgetRef ref) {
    final playerStateAsync = ref.watch(playerNotifierProvider);

    return playerStateAsync.when(
      data: (state) {
        final currentTrack = state.currentTrack;
        if (currentTrack == null) return null;

        final hasNetworkImage = currentTrack.coverUrl != null && currentTrack.coverUrl!.isNotEmpty && currentTrack.coverUrl!.startsWith('http');

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerPage()));
          },
          child: Container(
            color: const Color(0xFF16162A),
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: hasNetworkImage
                      ? Image.network(
                          currentTrack.coverUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.asset('assets/images/album_placeholder.png', width: 48, height: 48, fit: BoxFit.cover),
                        )
                      : Image.asset('assets/images/album_placeholder.png', width: 48, height: 48, fit: BoxFit.cover),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTrack.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentTrack.artistIds.isNotEmpty ? currentTrack.artistIds.first : 'Đang phát',
                        style: const TextStyle(color: Colors.cyanAccent, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                FavoriteButton(trackId: currentTrack.id, size: 24),
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                  onPressed: () {
                    ref.read(playerNotifierProvider.notifier).previousTrack();
                  },
                ),
                IconButton(
                  icon: Icon(
                    state.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                    color: Colors.cyanAccent,
                    size: 36,
                  ),
                  onPressed: () {
                    ref.read(playerNotifierProvider.notifier).togglePlay();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                  onPressed: () {
                    ref.read(playerNotifierProvider.notifier).nextTrack();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  onPressed: () {
                    ref.read(playerNotifierProvider.notifier).stop();
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}
