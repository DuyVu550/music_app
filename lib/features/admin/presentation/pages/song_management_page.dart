import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/admin_controller.dart';
import 'add_edit_song_page.dart';

class SongManagementPage extends ConsumerStatefulWidget {
  const SongManagementPage({super.key});

  @override
  ConsumerState<SongManagementPage> createState() => _SongManagementPageState();
}

class _SongManagementPageState extends ConsumerState<SongManagementPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final songsAsyncValue = ref.watch(songsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài hát...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          
          // Song List
          Expanded(
            child: songsAsyncValue.when(
              data: (songs) {
                final filteredSongs = songs.where((song) {
                  return song.title.toLowerCase().contains(_searchQuery) ||
                         song.artist.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredSongs.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy bài hát nào.', style: TextStyle(color: Colors.white54)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = filteredSongs[index];
                    return Card(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: song.coverUrl.isNotEmpty 
                            ? Image.network(song.coverUrl, width: 50, height: 50, fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.music_note, color: Colors.cyanAccent, size: 40))
                            : const Icon(Icons.music_note, color: Colors.cyanAccent, size: 40),
                        ),
                        title: Text(song.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(song.artist, style: const TextStyle(color: Colors.white70)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => AddEditSongPage(song: song)),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(context, ref, song.id, song.title),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
              error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditSongPage()),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text('Xóa Bài Hát', style: TextStyle(color: Colors.white)),
        content: Text('Bạn có chắc chắn muốn xóa bài hát "$title"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              ref.read(adminControllerProvider).deleteSong(id);
              Navigator.pop(ctx);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
