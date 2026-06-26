import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/admin_controller.dart';
import 'add_edit_artist_page.dart';

class ArtistManagementPage extends ConsumerStatefulWidget {
  const ArtistManagementPage({super.key});

  @override
  ConsumerState<ArtistManagementPage> createState() => _ArtistManagementPageState();
}

class _ArtistManagementPageState extends ConsumerState<ArtistManagementPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final artistsAsyncValue = ref.watch(artistsStreamProvider);

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
                hintText: 'Tìm kiếm nghệ sĩ...',
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

          // Artist List
          Expanded(
            child: artistsAsyncValue.when(
              data: (artists) {
                final filteredArtists = artists.where((artist) {
                  return artist.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredArtists.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy nghệ sĩ nào.', style: TextStyle(color: Colors.white54)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredArtists.length,
                  itemBuilder: (context, index) {
                    final artist = filteredArtists[index];
                    return Card(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: artist.imageUrl.isNotEmpty
                              ? Image.network(
                                  artist.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, color: Colors.cyanAccent, size: 40),
                                )
                              : const Icon(Icons.person, color: Colors.cyanAccent, size: 40),
                        ),
                        title: Text(
                          artist.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditArtistPage(artist: artist),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
              error: (err, stack) =>
                  Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
        ],
      ),
    );
  }
}
