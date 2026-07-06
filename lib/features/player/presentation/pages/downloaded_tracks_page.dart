import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/offline_track_service.dart';
import '../../domain/entities/track.dart';
import '../controllers/player_notifier.dart';

final downloadedTracksProvider = FutureProvider<List<Track>>((ref) async {
  return ref.read(offlineTrackServiceProvider).getDownloadedTracks();
});

class DownloadedTracksPage extends ConsumerWidget {
  const DownloadedTracksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(downloadedTracksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
        title: const Text(
          'Nhạc Đã Tải',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () => ref.invalidate(downloadedTracksProvider),
          ),
        ],
      ),
      body: tracksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
        error: (e, _) => Center(
          child: Text(
            'Lỗi: $e',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (tracks) {
          if (tracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.download_for_offline_rounded,
                      color: Colors.white24,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chưa có nhạc tải về',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tải bài hát để nghe khi không có mạng',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Play all button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '${tracks.length} bài hát',
                      style: const TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(playerNotifierProvider.notifier)
                            .playPlaylist(tracks, initialIndex: 0);
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: const Text('Phát tất cả'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    return _DownloadedTrackTile(
                      track: track,
                      onDelete: () async {
                        await ref
                            .read(offlineTrackServiceProvider)
                            .deleteTrack(track.id);
                        ref.invalidate(downloadedTracksProvider);
                      },
                      onPlay: () {
                        ref
                            .read(playerNotifierProvider.notifier)
                            .playPlaylist(tracks, initialIndex: index);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DownloadedTrackTile extends StatelessWidget {
  final Track track;
  final VoidCallback onDelete;
  final VoidCallback onPlay;

  const _DownloadedTrackTile({
    required this.track,
    required this.onDelete,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onTap: onPlay,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: track.coverUrl != null && track.coverUrl!.startsWith('http')
              ? Image.network(
                  track.coverUrl!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(),
                )
              : _placeholder(),
        ),
        title: Text(
          track.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.download_done_rounded,
                color: Colors.cyanAccent, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                track.artistIds.isNotEmpty
                    ? track.artistIds.first
                    : 'Unknown Artist',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 22),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1E2035),
                    title: const Text('Xóa bản tải',
                        style: TextStyle(color: Colors.white)),
                    content: Text(
                      'Xóa bản tải cục bộ của "${track.title}"?',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Hủy',
                            style: TextStyle(color: Colors.white54)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete();
                        },
                        child: const Text('Xóa',
                            style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2035), Color(0xFF2D3054)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note_rounded,
          color: Colors.cyanAccent, size: 24),
    );
  }
}
