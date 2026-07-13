import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/playlist.dart';
import '../controllers/playlist_notifier.dart';
import '../../../explore/presentation/controllers/all_tracks_notifier.dart';
import '../../../player/domain/entities/track.dart';

class AddSongsToPlaylistSheet extends ConsumerStatefulWidget {
  final Playlist playlist;

  const AddSongsToPlaylistSheet({super.key, required this.playlist});

  @override
  ConsumerState<AddSongsToPlaylistSheet> createState() => _AddSongsToPlaylistSheetState();
}

class _AddSongsToPlaylistSheetState extends ConsumerState<AddSongsToPlaylistSheet> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allTracksAsync = ref.watch(allTracksProvider);
    final playlistsAsync = ref.watch(userPlaylistsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF16162A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: playlistsAsync.when(
          data: (playlists) {
            // Get the latest state of this playlist
            final currentPlaylist = playlists.firstWhere(
              (p) => p.id == widget.playlist.id,
              orElse: () => widget.playlist,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Thêm bài hát vào Playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.toLowerCase().trim();
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tìm bài hát hoặc nghệ sĩ...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                        prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white54),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white10, height: 1),
                Flexible(
                  child: allTracksAsync.when(
                    data: (allTracks) {
                      // Filter tracks based on search query
                      final filteredTracks = allTracks.where((track) {
                        final title = track.title.toLowerCase();
                        final artist = track.artistIds.isNotEmpty
                            ? track.artistIds.first.toLowerCase()
                            : '';
                        return title.contains(_searchQuery) || artist.contains(_searchQuery);
                      }).toList();

                      if (filteredTracks.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          alignment: Alignment.center,
                          child: const Text(
                            'Không tìm thấy bài hát nào.',
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredTracks.length,
                        itemBuilder: (context, index) {
                          final Track track = filteredTracks[index];
                          final isAdded = currentPlaylist.trackIds.contains(track.id);
                          final hasNetworkImage = track.coverUrl != null && (track.coverUrl!.startsWith('http') || track.coverUrl!.startsWith('data:'));

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: hasNetworkImage
                                  ? Image.network(
                                      track.coverUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Image.asset(
                                        'assets/images/album_placeholder.png',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/album_placeholder.png',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            title: Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              track.artistIds.isNotEmpty ? track.artistIds.first : 'Unknown Artist',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                color: isAdded ? Colors.cyanAccent : Colors.white54,
                              ),
                              onPressed: () async {
                                final controller = ref.read(playlistControllerProvider);
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  if (isAdded) {
                                    await controller.removeTrackFromPlaylist(currentPlaylist.id, track.id);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFF16162A),
                                        duration: const Duration(seconds: 1),
                                        content: Text('Đã xóa "${track.title}" khỏi playlist'),
                                      ),
                                    );
                                  } else {
                                    await controller.addTrackToPlaylist(currentPlaylist.id, track.id);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        backgroundColor: const Color(0xFF16162A),
                                        duration: const Duration(seconds: 1),
                                        content: Text('Đã thêm "${track.title}" vào playlist'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.redAccent,
                                      content: Text('Lỗi: $e'),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(color: Colors.cyanAccent),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent)),
            ),
          ),
        ),
      ),
    );
  }
}
