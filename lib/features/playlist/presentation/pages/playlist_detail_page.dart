import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/playlist.dart';
import '../controllers/playlist_notifier.dart';
import '../../../explore/presentation/controllers/all_tracks_notifier.dart';
import '../../../player/domain/entities/track.dart';
import '../../../player/presentation/controllers/player_notifier.dart';
import '../../../player/presentation/pages/player_page.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../widgets/add_songs_to_playlist_sheet.dart';

class PlaylistDetailPage extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  void _showAddSongsSheet(BuildContext context, Playlist currentPlaylist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => AddSongsToPlaylistSheet(playlist: currentPlaylist),
      ),
    );
  }

  void _showRemoveConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    Playlist currentPlaylist,
    Track track,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16162A),
          title: const Text(
            'Xóa khỏi Playlist',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa "${track.title}" khỏi playlist "${currentPlaylist.name}" không?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                try {
                  await ref
                      .read(playlistControllerProvider)
                      .removeTrackFromPlaylist(currentPlaylist.id, track.id);
                  messenger.showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF16162A),
                      content: Text('Đã xóa "${track.title}" khỏi playlist'),
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('Lỗi khi xóa: $e'),
                    ),
                  );
                }
              },
              child: const Text(
                'Xóa',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(userPlaylistsProvider);
    final allTracksAsync = ref.watch(allTracksProvider);

    return playlistsAsync.when(
      data: (playlists) {
        // Find latest version of this playlist
        final currentPlaylist = playlists.firstWhere(
          (p) => p.id == playlist.id,
          orElse: () => playlist,
        );

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F1E),
          body: allTracksAsync.when(
            data: (allTracks) {
              // Map IDs to actual Track objects
              final tracks = currentPlaylist.trackIds
                  .map((id) {
                    try {
                      return allTracks.firstWhere((t) => t.id == id);
                    } catch (e) {
                      return null;
                    }
                  })
                  .whereType<Track>()
                  .toList();

              final hasImage =
                  currentPlaylist.coverUrl != null &&
                  currentPlaylist.coverUrl!.isNotEmpty;

              return CustomScrollView(
                slivers: [
                  // App Bar with Collapsing Header
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    backgroundColor: const Color(0xFF0F0F1E),
                    elevation: 0,
                    iconTheme: const IconThemeData(color: Colors.white),
                    actions: [
                      IconButton(
                        icon: const Icon(
                          Icons.playlist_add_rounded,
                          color: Colors.cyanAccent,
                          size: 28,
                        ),
                        tooltip: 'Thêm bài hát',
                        onPressed: () => _showAddSongsSheet(context, currentPlaylist),
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Cover Image or Default Gradient
                          hasImage
                              ? Image.network(
                                  currentPlaylist.coverUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1F3C75),
                                        Color(0xFF0F0F1E),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.queue_music_rounded,
                                    size: 80,
                                    color: Colors.white24,
                                  ),
                                ),
                          // Gradient Overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.transparent,
                                  const Color(0xFF0F0F1E),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: const [0.0, 0.6, 1.0],
                              ),
                            ),
                          ),
                          // Content Info
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentPlaylist.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  currentPlaylist.description ??
                                      'Không có mô tả',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 13,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${tracks.length} bài hát',
                                  style: const TextStyle(
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions Section
                  if (tracks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(playerNotifierProvider.notifier)
                                      .playPlaylist(tracks, initialIndex: 0);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PlayerPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  'Phát tất cả',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final shuffled = List<Track>.from(tracks)
                                    ..shuffle();
                                  ref
                                      .read(playerNotifierProvider.notifier)
                                      .playPlaylist(shuffled, initialIndex: 0);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PlayerPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.shuffle,
                                  color: Colors.cyanAccent,
                                ),
                                label: const Text(
                                  'Phát ngẫu nhiên',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.cyanAccent,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Songs List
                  if (tracks.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.music_off_rounded,
                              size: 64,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Không có bài hát nào trong playlist này.',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _showAddSongsSheet(context, currentPlaylist),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Thêm bài hát'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final track = tracks[index];
                        final hasNetworkImage =
                            track.coverUrl != null &&
                            track.coverUrl!.startsWith('http');
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 6,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: hasNetworkImage
                                ? Image.network(
                                    track.coverUrl!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Image.asset(
                                          'assets/images/album_placeholder.png',
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                        ),
                                  )
                                : Image.asset(
                                    'assets/images/album_placeholder.png',
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          title: Text(
                            track.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            track.artistIds.isNotEmpty
                                ? track.artistIds.first
                                : 'Unknown Artist',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FavoriteButton(trackId: track.id, size: 20),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white70,
                                ),
                                color: const Color(0xFF16162A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) {
                                  if (value == 'remove') {
                                    _showRemoveConfirmDialog(
                                      context,
                                      ref,
                                      currentPlaylist,
                                      track,
                                    );
                                  } else if (value == 'add_queue') {
                                    ref
                                        .read(playerNotifierProvider.notifier)
                                        .addToQueue(track);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(
                                          0xFF16162A,
                                        ),
                                        content: Text(
                                          'Đã thêm "${track.title}" vào danh sách phát',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(
                                    value: 'add_queue',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.queue_music_rounded,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Thêm vào hàng chờ',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Xóa khỏi Playlist',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .playPlaylist(tracks, initialIndex: index);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PlayerPage(),
                              ),
                            );
                          },
                        );
                      }, childCount: tracks.length),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100), // Space for bottom player
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
            error: (err, _) => Center(
              child: Text(
                'Lỗi tải bài hát: $err',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F0F1E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        body: Center(
          child: Text(
            'Lỗi: $err',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
