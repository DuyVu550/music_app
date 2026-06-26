import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/favorite_notifier.dart';
import '../../../explore/presentation/controllers/all_tracks_notifier.dart';
import '../../../player/domain/entities/track.dart';
import '../../../player/presentation/controllers/player_notifier.dart';
import '../../../player/presentation/pages/player_page.dart';
import '../widgets/favorite_button.dart';
import '../../../player/presentation/widgets/song_options_bottom_sheet.dart';

class FavoriteSongsPage extends ConsumerWidget {
  const FavoriteSongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteNotifierProvider);
    final allTracksAsync = ref.watch(allTracksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Bài hát yêu thích', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, color: Colors.white38, size: 64),
                  SizedBox(height: 16),
                  Text('Bạn chưa có bài hát yêu thích nào', style: TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
            );
          }

          return allTracksAsync.when(
            data: (allTracks) {
              // Map favorite IDs to actual Track objects
              final favoriteTracks = favorites.map((fav) {
                try {
                  return allTracks.firstWhere((t) => t.id == fav.trackId);
                } catch (e) {
                  return null;
                }
              }).whereType<Track>().toList();

              if (favoriteTracks.isEmpty) {
                return const Center(
                  child: Text('Không tìm thấy dữ liệu bài hát', style: TextStyle(color: Colors.white54, fontSize: 16)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: favoriteTracks.length,
                itemBuilder: (context, index) {
                  final track = favoriteTracks[index];
                  final hasNetworkImage = track.coverUrl != null && track.coverUrl!.startsWith('http');

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: hasNetworkImage
                          ? Image.network(
                              track.coverUrl!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/album_placeholder.png', width: 56, height: 56, fit: BoxFit.cover),
                            )
                          : Image.asset(
                              'assets/images/album_placeholder.png',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                    ),
                    title: Text(track.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(track.artistIds.isNotEmpty ? track.artistIds.first : 'Unknown Artist', style: const TextStyle(color: Colors.white54)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FavoriteButton(trackId: track.id, size: 24),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white70),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SongOptionsBottomSheet(track: track),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      ref.read(playerNotifierProvider.notifier).playTrack(track);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerPage()));
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
            error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent))),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
        error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }
}
