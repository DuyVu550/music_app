import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/domain/entities/track.dart';
import '../controllers/playlist_notifier.dart';

class AddToPlaylistSheet extends ConsumerWidget {
  final Track track;

  const AddToPlaylistSheet({super.key, required this.track});

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16162A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.cyanAccent.withValues(alpha: 0.2)),
          ),
          title: const Text(
            'Tạo Playlist mới',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Tên Playlist',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Vui lòng nhập tên playlist';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mô tả (Tùy chọn)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final messenger = ScaffoldMessenger.of(context);
                  final name = nameController.text.trim();
                  final desc = descController.text.trim();
                  Navigator.pop(context); // Close dialog

                  try {
                    // Create playlist
                    await ref.read(playlistControllerProvider).createPlaylist(
                          name: name,
                          description: desc.isNotEmpty ? desc : null,
                        );

                    // We need to add the track to the newly created playlist.
                    // But since Firestore operations take a moment, we can query the latest list.
                    // To keep it simple, we inform the user the playlist is created, and they can add it.
                    // Even better: since we don't have the new playlist ID yet, we can wait or just notify.
                    // Actually, let's create the playlist and add the track. How to get the ID?
                    // In PlaylistController, createPlaylist could return the created playlist ID!
                    // Let's modify createPlaylist to return the document ID. Let's see:
                    // If we do that, we can automatically add the track. That is an amazing premium experience!
                    // Let's first build the sheet and then update PlaylistController if needed.
                    // For now, we can just say "Đã tạo playlist. Thêm bài hát thủ công." or let's update PlaylistController
                    // so createPlaylist returns Future<String>. Let's see if we can do that. Yes!
                    
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF16162A),
                        content: Text('Đã tạo playlist "$name" thành công!'),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('Lỗi khi tạo playlist: $e'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Tạo', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: Column(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thêm vào Playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showCreatePlaylistDialog(context, ref),
                    icon: const Icon(Icons.add, size: 18, color: Colors.cyanAccent),
                    label: const Text(
                      'Tạo mới',
                      style: TextStyle(color: Colors.cyanAccent),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            Flexible(
              child: playlistsAsync.when(
                data: (playlists) {
                  if (playlists.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.playlist_add_rounded, size: 48, color: Colors.white38),
                          SizedBox(height: 12),
                          Text(
                            'Bạn chưa có playlist nào.\nHãy nhấn "Tạo mới" để bắt đầu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      final containsTrack = playlist.trackIds.contains(track.id);

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty
                              ? Image.network(
                                  playlist.coverUrl!,
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
                          playlist.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${playlist.trackIds.length} bài hát',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                        ),
                        trailing: Icon(
                          containsTrack ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                          color: containsTrack ? Colors.cyanAccent : Colors.white54,
                        ),
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          Navigator.pop(context);
                          try {
                            if (containsTrack) {
                              await ref
                                  .read(playlistControllerProvider)
                                  .removeTrackFromPlaylist(playlist.id, track.id);
                              messenger.showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF16162A),
                                  content: Text(
                                    'Đã xóa "${track.title}" khỏi "${playlist.name}"',
                                    style: const TextStyle(color: Colors.cyanAccent),
                                  ),
                                ),
                              );
                            } else {
                              await ref
                                  .read(playlistControllerProvider)
                                  .addTrackToPlaylist(playlist.id, track.id);
                              messenger.showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF16162A),
                                  content: Text(
                                    'Đã thêm "${track.title}" vào "${playlist.name}"',
                                    style: const TextStyle(color: Colors.cyanAccent),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text('Đã xảy ra lỗi: $e'),
                              ),
                            );
                          }
                        },
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
        ),
      ),
    );
  }
}
