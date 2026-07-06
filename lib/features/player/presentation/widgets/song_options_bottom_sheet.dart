import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track.dart';
import '../controllers/player_notifier.dart';
import '../../../playlist/presentation/widgets/add_to_playlist_sheet.dart';
import '../../data/datasources/offline_track_service.dart';

class SongOptionsBottomSheet extends ConsumerWidget {
  final Track track;

  const SongOptionsBottomSheet({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNetworkImage =
        track.coverUrl != null &&
        track.coverUrl!.isNotEmpty &&
        track.coverUrl!.startsWith('http');

    final playerState = ref.watch(playerNotifierProvider).value;
    final isInQueue =
        playerState?.playlist.any((t) => t.id == track.id) ?? false;

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
            // Bottom sheet drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Track details header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasNetworkImage
                        ? Image.network(
                            track.coverUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/images/album_placeholder.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/album_placeholder.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track.artistIds.isNotEmpty
                              ? track.artistIds.first
                              : 'Unknown Artist',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white10, height: 1),
            // Options list
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Download tile with real status
                    _DownloadTile(track: track),
                    ListTile(
                      leading: const Icon(
                        Icons.playlist_play_rounded,
                        color: Colors.white70,
                      ),
                      title: const Text(
                        'Ưu tiên phát kế tiếp',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(playerNotifierProvider.notifier).playNext(track);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF16162A),
                            content: Text(
                              'Đã xếp "${track.title}" phát tiếp theo.',
                              style: const TextStyle(color: Colors.cyanAccent),
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.queue_music_rounded,
                        color: Colors.white70,
                      ),
                      title: const Text(
                        'Thêm vào danh sách phát',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ref.read(playerNotifierProvider.notifier).addToQueue(track);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF16162A),
                            content: Text(
                              'Đã thêm "${track.title}" vào danh sách phát.',
                              style: const TextStyle(color: Colors.cyanAccent),
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.playlist_add_rounded,
                        color: Colors.white70,
                      ),
                      title: const Text(
                        'Thêm vào Playlist',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => AddToPlaylistSheet(track: track),
                        );
                      },
                    ),
                    if (isInQueue)
                      ListTile(
                        leading: const Icon(
                          Icons.remove_circle_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          'Xóa khỏi danh sách phát',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          ref
                              .read(playerNotifierProvider.notifier)
                              .removeFromQueue(track);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF16162A),
                              content: Text(
                                'Đã xóa "${track.title}" khỏi danh sách phát.',
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
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

/// A download tile that shows real download status using ValueListenableBuilder.
class _DownloadTile extends ConsumerStatefulWidget {
  final Track track;

  const _DownloadTile({required this.track});

  @override
  ConsumerState<_DownloadTile> createState() => _DownloadTileState();
}

class _DownloadTileState extends ConsumerState<_DownloadTile> {
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    final result = await ref
        .read(offlineTrackServiceProvider)
        .isTrackDownloaded(widget.track.id);
    if (mounted) setState(() => _isDownloaded = result);
  }

  @override
  Widget build(BuildContext context) {
    final offlineService = ref.read(offlineTrackServiceProvider);
    final progressNotifier = offlineService.getProgressNotifier(widget.track.id);

    return ValueListenableBuilder<DownloadProgress>(
      valueListenable: progressNotifier,
      builder: (context, progress, _) {
        final isDownloading = progress.progress > 0.0 && !progress.isDone;

        if (_isDownloaded) {
          // Show "Xóa bản tải" option
          return ListTile(
            leading: const Icon(
              Icons.download_done_rounded,
              color: Colors.cyanAccent,
            ),
            title: const Text(
              'Đã tải offline',
              style: TextStyle(color: Colors.cyanAccent),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 20),
              onPressed: () async {
                await offlineService.deleteTrack(widget.track.id);
                if (mounted) setState(() => _isDownloaded = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Đã xóa bản tải cục bộ.'),
                  ));
                }
              },
            ),
          );
        }

        if (isDownloading) {
          return ListTile(
            leading: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                value: progress.progress,
                color: Colors.cyanAccent,
                strokeWidth: 2.5,
              ),
            ),
            title: Text(
              'Đang tải... ${(progress.progress * 100).toInt()}%',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        // Default: show download option
        return ListTile(
          leading: const Icon(
            Icons.download_rounded,
            color: Colors.cyanAccent,
          ),
          title: const Text(
            'Tải để nghe offline',
            style: TextStyle(color: Colors.white),
          ),
          onTap: () async {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF16162A),
                content: Text(
                  'Bắt đầu tải "${widget.track.title}"...',
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
              ),
            );
            await offlineService.downloadTrack(widget.track);
            if (mounted) setState(() => _isDownloaded = true);
          },
        );
      },
    );
  }
}
