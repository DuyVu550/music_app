import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/playlist_notifier.dart';
import '../../domain/entities/playlist.dart';
import 'playlist_detail_page.dart';

class MyPlaylistsPage extends ConsumerWidget {
  const MyPlaylistsPage({super.key});

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final coverUrlController = TextEditingController();
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
          content: SingleChildScrollView(
            child: Form(
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: coverUrlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Link ảnh bìa (Tùy chọn)',
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
                  final cover = coverUrlController.text.trim();
                  Navigator.pop(context);

                  try {
                    await ref.read(playlistControllerProvider).createPlaylist(
                          name: name,
                          description: desc.isNotEmpty ? desc : null,
                          coverUrl: cover.isNotEmpty ? cover : null,
                        );
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

  void _showEditPlaylistDialog(BuildContext context, WidgetRef ref, Playlist playlist) {
    final nameController = TextEditingController(text: playlist.name);
    final descController = TextEditingController(text: playlist.description);
    final coverUrlController = TextEditingController(text: playlist.coverUrl);
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
            'Sửa thông tin Playlist',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
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
                      labelText: 'Mô tả',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyanAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: coverUrlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Link ảnh bìa',
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
                  final cover = coverUrlController.text.trim();
                  Navigator.pop(context);

                  try {
                    await ref.read(playlistControllerProvider).updatePlaylist(
                          playlist.copyWith(
                            name: name,
                            description: desc.isNotEmpty ? desc : null,
                            coverUrl: cover.isNotEmpty ? cover : null,
                          ),
                        );
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF16162A),
                        content: Text('Đã cập nhật playlist "$name" thành công!'),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('Lỗi khi sửa playlist: $e'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Lưu', style: TextStyle(color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, Playlist playlist) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16162A),
          title: const Text('Xóa Playlist', style: TextStyle(color: Colors.white)),
          content: Text(
            'Bạn có chắc chắn muốn xóa playlist "${playlist.name}" không? Hành động này không thể hoàn tác.',
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
                  await ref.read(playlistControllerProvider).deletePlaylist(playlist.id);
                  messenger.showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF16162A),
                      content: Text('Đã xóa playlist "${playlist.name}"'),
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
              child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(userPlaylistsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        title: const Text(
          'Playlist của tôi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.cyanAccent, size: 28),
            onPressed: () => _showCreatePlaylistDialog(context, ref),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F0F1E), Color(0xFF16162A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: playlistsAsync.when(
          data: (playlists) {
            if (playlists.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.library_music_outlined, size: 80, color: Colors.white24),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có Playlist nào',
                      style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo danh sách phát cá nhân đầu tiên của bạn!',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showCreatePlaylistDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Tạo Playlist'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final hasImage = playlist.coverUrl != null && playlist.coverUrl!.isNotEmpty;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistDetailPage(playlist: playlist),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              hasImage
                                  ? Image.network(
                                      playlist.coverUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: Colors.cyanAccent.withValues(alpha: 0.1),
                                        child: const Icon(Icons.music_note_rounded, size: 50, color: Colors.cyanAccent),
                                      ),
                                    )
                                  : Container(
                                      color: Colors.cyanAccent.withValues(alpha: 0.1),
                                      child: const Icon(Icons.music_note_rounded, size: 50, color: Colors.cyanAccent),
                                    ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Colors.white),
                                  color: const Color(0xFF16162A),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _showEditPlaylistDialog(context, ref, playlist);
                                    } else if (value == 'delete') {
                                      _showDeleteConfirmDialog(context, ref, playlist);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.white70, size: 18),
                                          SizedBox(width: 8),
                                          Text('Sửa', style: TextStyle(color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                          SizedBox(width: 8),
                                          Text('Xóa', style: TextStyle(color: Colors.redAccent)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                playlist.description ?? 'Không có mô tả',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${playlist.trackIds.length} bài hát',
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
          error: (err, _) => Center(
            child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent)),
          ),
        ),
      ),
    );
  }
}
