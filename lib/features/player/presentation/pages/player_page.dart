import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track.dart';
import '../controllers/player_notifier.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';

import 'package:music_app/features/player/presentation/widgets/global_bottom_player.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key});

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> {
  late final BottomPlayerVisibilityNotifier _visibilityNotifier;

  @override
  void initState() {
    super.initState();
    _visibilityNotifier = ref.read(bottomPlayerVisibilityProvider.notifier);
    Future.microtask(() {
      _visibilityNotifier.setVisibility(false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibilityNotifier.setVisibility(true);
    });
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final playerStateAsync = ref.watch(playerNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Đang Phát', style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: playerStateAsync.when(
        data: (state) {
          final track = state.currentTrack;
          if (track == null) {
            return const Center(
              child: Text('Không có bài hát nào đang phát', style: TextStyle(color: Colors.white)),
            );
          }

          return Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Album Art with shadow
                      // Spinning Album Art (Vinyl Style)
                      SpinningAlbumArt(
                        track: track,
                        isPlaying: state.isPlaying,
                      ),
                      const SizedBox(height: 32),

                      // Title and Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 32), // Balance spacing
                                Expanded(
                                  child: Text(
                                    track.title,
                                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                FavoriteButton(trackId: track.id, size: 28),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              track.artistIds.isNotEmpty ? track.artistIds.first : 'Nghệ sĩ chưa rõ',
                              style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Slider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            Builder(
                              builder: (context) {
                                double safeMax = state.duration.inSeconds > 0
                                    ? state.duration.inSeconds.toDouble()
                                    : (track.durationMs / 1000).toDouble();
                                if (safeMax <= 0) safeMax = 1.0; // Prevent 0 max
                                
                                double safeValue = state.position.inSeconds.toDouble();
                                if (safeValue > safeMax) safeValue = safeMax;
                                if (safeValue < 0) safeValue = 0;

                                return Slider(
                                  value: safeValue,
                                  min: 0,
                                  max: safeMax,
                                  activeColor: Colors.cyanAccent,
                                  inactiveColor: Colors.white12,
                                  onChanged: (val) {
                                    ref.read(playerNotifierProvider.notifier).seek(Duration(seconds: val.toInt()));
                                  },
                                );
                              }
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(state.position), style: const TextStyle(color: Colors.white60)),
                                  Text(
                                    _formatDuration(state.duration.inSeconds > 0
                                        ? state.duration
                                        : Duration(milliseconds: track.durationMs)),
                                    style: const TextStyle(color: Colors.white60),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                            onPressed: () {
                              ref.read(playerNotifierProvider.notifier).previousTrack();
                            },
                          ),
                          const SizedBox(width: 24),
                          GestureDetector(
                            onTap: () {
                              ref.read(playerNotifierProvider.notifier).togglePlay();
                            },
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: Colors.cyanAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                            onPressed: () {
                              ref.read(playerNotifierProvider.notifier).nextTrack();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
              
              // Draggable Playlist Bottom Sheet
              DraggableScrollableSheet(
                initialChildSize: 0.15,
                minChildSize: 0.15,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return Material(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        SingleChildScrollView(
                          controller: scrollController,
                          physics: const ClampingScrollPhysics(),
                          child: Container(
                            color: const Color(0xFF1A1A2E),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                                    width: 40,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.white38,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 24.0, bottom: 12.0),
                                  child: Text(
                                    'Danh Sách Đang Phát',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: state.playlist.length,
                            itemBuilder: (context, index) {
                              final item = state.playlist[index];
                              final isCurrent = item.id == track.id;
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: (item.coverUrl != null && item.coverUrl!.startsWith('http'))
                                      ? Image.network(
                                          item.coverUrl!,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Image.asset('assets/images/album_placeholder.png', width: 40, height: 40, fit: BoxFit.cover),
                                        )
                                      : Image.asset(
                                          item.coverUrl ?? 'assets/images/album_placeholder.png',
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: isCurrent ? Colors.cyanAccent : Colors.white,
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                trailing: isCurrent
                                    ? const Icon(Icons.volume_up, color: Colors.cyanAccent)
                                    : null,
                                onTap: () {
                                  ref.read(playerNotifierProvider.notifier).playTrack(item);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
        error: (e, s) => Center(child: Text('Lỗi: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class SpinningAlbumArt extends StatefulWidget {
  final Track track;
  final bool isPlaying;

  const SpinningAlbumArt({super.key, required this.track, required this.isPlaying});

  @override
  State<SpinningAlbumArt> createState() => _SpinningAlbumArtState();
}

class _SpinningAlbumArtState extends State<SpinningAlbumArt> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SpinningAlbumArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.141592653589793,
            child: child,
          );
        },
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: (widget.track.coverUrl != null && widget.track.coverUrl!.startsWith('http'))
                    ? Image.network(
                        widget.track.coverUrl!,
                        width: 280,
                        height: 280,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset('assets/images/album_placeholder.png', width: 280, height: 280, fit: BoxFit.cover),
                      )
                    : Image.asset(
                        widget.track.coverUrl ?? 'assets/images/album_placeholder.png',
                        width: 280,
                        height: 280,
                        fit: BoxFit.cover,
                      ),
              ),
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26, width: 2),
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                    stops: const [0.3, 0.6, 0.9, 1.0],
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F1E),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black54, width: 2),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


