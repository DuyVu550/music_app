import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/domain/entities/album.dart';
import '../../../player/data/repositories/album_repository_impl.dart';
import 'add_edit_album_page.dart';

final albumsStreamProvider = StreamProvider<List<Album>>((ref) {
  return ref.read(albumRepositoryImplProvider).getAllAlbumsStream();
});

class AlbumManagementPage extends ConsumerWidget {
  const AlbumManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: albumsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
        error: (e, _) => Center(
          child: Text('Lỗi: $e', style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (albums) {
          if (albums.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.album_rounded,
                      color: Colors.white24,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có Album nào',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nhấn + để tạo album đầu tiên',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: albums.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final album = albums[index];
              return _AlbumTile(album: album);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditAlbumPage(),
            ),
          );
        },
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm Album', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _AlbumTile extends ConsumerWidget {
  final Album album;

  const _AlbumTile({required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: album.coverUrl != null && (album.coverUrl!.startsWith('http') || album.coverUrl!.startsWith('data:'))
              ? Image.network(
                  album.coverUrl!,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _placeholder(),
                )
              : _placeholder(),
        ),
        title: Text(
          album.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (album.artistIds.isNotEmpty)
              Text(
                album.artistIds.join(', '),
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (album.releaseYear > 0)
              Text(
                '${album.releaseYear}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
          ],
        ),
        isThreeLine: album.artistIds.isNotEmpty && album.releaseYear > 0,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white54, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditAlbumPage(album: album),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 20),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 54,
      height: 54,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E2035), Color(0xFF2D3054)],
        ),
      ),
      child: const Icon(Icons.album_rounded, color: Colors.cyanAccent, size: 28),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2035),
        title: const Text('Xóa Album', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc muốn xóa album "${album.title}"?\n(Bài hát trong album sẽ không bị xóa)',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(albumRepositoryImplProvider).deleteAlbum(album.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa album "${album.title}"'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
