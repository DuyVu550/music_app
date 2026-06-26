import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/player_notifier.dart';
import '../pages/player_page.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../../../core/utils/navigation_service.dart';

class BottomPlayerVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void setVisibility(bool visible) {
    if (ref.mounted) {
      state = visible;
    }
  }
}

final bottomPlayerVisibilityProvider = NotifierProvider<BottomPlayerVisibilityNotifier, bool>(BottomPlayerVisibilityNotifier.new);

class GlobalBottomPlayerWidget extends ConsumerWidget {
  const GlobalBottomPlayerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(bottomPlayerVisibilityProvider);
    if (!isVisible) return const SizedBox.shrink();

    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;
    if (user == null || user.role == UserRole.admin) {
      return const SizedBox.shrink();
    }

    final playerStateAsync = ref.watch(playerNotifierProvider);

    return playerStateAsync.when(
      data: (state) {
        final currentTrack = state.currentTrack;
        if (currentTrack == null) return const SizedBox.shrink();

        final hasNetworkImage = currentTrack.coverUrl != null &&
            currentTrack.coverUrl!.isNotEmpty &&
            currentTrack.coverUrl!.startsWith('http');

        return GestureDetector(
          onTap: () {
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState!.push(
                MaterialPageRoute(builder: (context) => const PlayerPage()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayerPage()),
              );
            }
          },
          child: Container(
            color: const Color(0xFF16162A),
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: hasNetworkImage
                      ? Image.network(
                          currentTrack.coverUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.asset(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentTrack.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentTrack.artistIds.isNotEmpty ? currentTrack.artistIds.first : 'Đang phát',
                        style: const TextStyle(color: Colors.cyanAccent, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                FavoriteButton(trackId: currentTrack.id, size: 24),
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                  onPressed: () {
                    ref.read(playerNotifierProvider.notifier).previousTrack();
                  },
                ),
                IconButton(
                  icon: Icon(
                    state.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                    color: Colors.cyanAccent,
                    size: 36,
                  ),
                  onPressed: () {
                    ref.read(playerNotifierProvider.notifier).togglePlay();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                  onPressed: () {
                    ref.read(playerNotifierProvider.notifier).nextTrack();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  onPressed: () {
                    ref.read(playerNotifierProvider.notifier).stop();
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
