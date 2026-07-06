import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/domain/entities/album.dart';
import '../../../player/domain/entities/track.dart';
import '../../../player/domain/repositories/track_repository.dart';
import '../../../player/presentation/controllers/player_notifier.dart';
import '../../../player/presentation/widgets/song_options_bottom_sheet.dart';

final albumTracksProvider = FutureProvider.family<List<Track>, String>((ref, albumId) async {
  final repo = ref.read(trackRepositoryProvider);
  final allTracks = await repo.getAllTracks();
  return allTracks.where((track) => track.albumId == albumId).toList();
});

class AlbumSongsPage extends ConsumerWidget {
  final Album album;

  const AlbumSongsPage({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(albumTracksProvider(album.id));

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0F2027),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C5364), Color(0xFF203A43), Color(0xFF0F2027)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    // Album Cover
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: album.coverUrl != null && album.coverUrl!.startsWith('http')
                          ? Image.network(
                              album.coverUrl!,
                              width: 130,
                              height: 130,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                    const SizedBox(height: 14),
                    // Album Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        album.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Artist
                    Text(
                      album.artistIds.isNotEmpty ? album.artistIds.join(', ') : 'Unknown Artist',
                      style: const TextStyle(color: Colors.cyanAccent, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    // Release Year
                    if (album.releaseYear > 0)
                      Text(
                        'Album • ${album.releaseYear}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: tracksAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              ),
              error: (err, _) => Center(
                child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent)),
              ),
              data: (tracks) {
                if (tracks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.music_off_rounded, color: Colors.white24, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          'Chưa có bài hát nào trong Album này',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _TrackTile(
                      track: track,
                      index: index + 1,
                      onTap: () {
                        ref.read(playerNotifierProvider.notifier).playPlaylist(
                              tracks,
                              initialIndex: index,
                            );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.album_rounded, color: Colors.cyanAccent, size: 54),
    );
  }
}

class _TrackTile extends StatelessWidget {
  final Track track;
  final int index;
  final VoidCallback onTap;

  const _TrackTile({
    required this.track,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: SizedBox(
          width: 32,
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(color: Colors.white38, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        title: Text(
          track.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          track.artistIds.isNotEmpty ? track.artistIds.first : 'Unknown Artist',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatDuration(track.durationMs),
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white54),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => SongOptionsBottomSheet(track: track),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int ms) {
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

