import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../../player/domain/repositories/track_repository.dart';

// Provider to fetch listening history for the current user
final listeningHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(authNotifierProvider).value;
  if (user == null) return [];
  return ref.read(trackRepositoryProvider).getListeningHistory(user.id);
});

class MusicWrappedPage extends ConsumerWidget {
  const MusicWrappedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(listeningHistoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
        error: (e, _) => Center(
          child: Text('Lỗi: $e', style: const TextStyle(color: Colors.redAccent)),
        ),
        data: (history) => _WrappedContent(history: history),
      ),
    );
  }
}

class _WrappedContent extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const _WrappedContent({required this.history});

  @override
  Widget build(BuildContext context) {
    // -- Aggregate stats --
    final totalPlays = history.length;

    // Count plays per track
    final trackCounts = <String, int>{};
    final trackTitles = <String, String>{};
    final trackArtists = <String, String>{};
    final trackCovers = <String, String?>{};
    final artistCounts = <String, int>{};

    for (final entry in history) {
      final id = entry['trackId'] as String? ?? '';
      final title = entry['title'] as String? ?? 'Unknown';
      final artist = entry['artist'] as String? ?? 'Unknown';
      final cover = entry['coverUrl'] as String?;
      trackCounts[id] = (trackCounts[id] ?? 0) + 1;
      trackTitles[id] = title;
      trackArtists[id] = artist;
      trackCovers[id] = cover;
      artistCounts[artist] = (artistCounts[artist] ?? 0) + 1;
    }

    // Top 5 tracks
    final topTracks = trackCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5Tracks = topTracks.take(5).toList();

    // Top 5 artists
    final topArtists = artistCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5Artists = topArtists.take(5).toList();

    // Max plays for chart scaling
    final maxTrackPlays =
        top5Tracks.isNotEmpty ? top5Tracks.first.value : 1;

    return CustomScrollView(
      slivers: [
        // -- Header --
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: const Color(0xFF0A0A1A),
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A0533),
                    Color(0xFF0A2045),
                    Color(0xFF0A0A1A),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.cyanAccent, Colors.purpleAccent],
                    ).createShader(bounds),
                    child: const Text(
                      '🎶 Thống kê âm nhạc',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Khám phá thói quen nghe nhạc của bạn',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // -- Summary cards --
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.headphones_rounded,
                      label: 'Lượt nghe',
                      value: totalPlays.toString(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.music_note_rounded,
                      label: 'Bài hát khác nhau',
                      value: trackCounts.length.toString(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDA22FF), Color(0xFF9733EE)],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.person_rounded,
                      label: 'Nghệ sĩ đã nghe',
                      value: artistCounts.length.toString(),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8C00), Color(0xFFF44336)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer_rounded,
                      label: 'Phút nghe (ước tính)',
                      value: '~${(totalPlays * 3.5).toInt()}',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              if (history.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.bar_chart_rounded,
                          color: Colors.white24, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có dữ liệu nghe nhạc',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Nghe nhạc ≥ 30 giây để thống kê được ghi nhận',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else ...[
                // -- Top Tracks Chart --
                _SectionHeader(
                  icon: Icons.leaderboard_rounded,
                  title: 'Top bài hát của bạn',
                ),
                const SizedBox(height: 12),
                ...top5Tracks.asMap().entries.map((entry) {
                  final rank = entry.key;
                  final e = entry.value;
                  return _TrackBarRow(
                    rank: rank + 1,
                    title: trackTitles[e.key] ?? e.key,
                    artist: trackArtists[e.key] ?? '',
                    coverUrl: trackCovers[e.key],
                    plays: e.value,
                    maxPlays: maxTrackPlays,
                  );
                }),

                const SizedBox(height: 28),

                // -- Top Artists --
                _SectionHeader(
                  icon: Icons.people_rounded,
                  title: 'Nghệ sĩ yêu thích',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: top5Artists.asMap().entries.map((entry) {
                    return _ArtistChip(
                      rank: entry.key + 1,
                      name: entry.value.key,
                      plays: entry.value.value,
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // -- Recent History --
                _SectionHeader(
                  icon: Icons.history_rounded,
                  title: 'Nghe gần đây',
                ),
                const SizedBox(height: 12),
                ...history.take(10).map((entry) {
                  final title = entry['title'] as String? ?? 'Unknown';
                  final artist = entry['artist'] as String? ?? '';
                  final coverUrl = entry['coverUrl'] as String?;
                  final date = entry['listenedAt'] as String? ?? '';
                  return _RecentHistoryTile(
                    title: title,
                    artist: artist,
                    coverUrl: coverUrl,
                    date: date,
                  );
                }),
              ],

              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.cyanAccent, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TrackBarRow extends StatelessWidget {
  final int rank;
  final String title;
  final String artist;
  final String? coverUrl;
  final int plays;
  final int maxPlays;

  const _TrackBarRow({
    required this.rank,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.plays,
    required this.maxPlays,
  });

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.white38;
    }
  }

  @override
  Widget build(BuildContext context) {
    final barFraction = maxPlays > 0 ? plays / maxPlays : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rank == 1 ? const Color(0xFFFFD700).withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: _rankColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: coverUrl != null && (coverUrl!.startsWith('http') || coverUrl!.startsWith('data:'))
                ? Image.network(
                    coverUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _coverPlaceholder(),
                  )
                : _coverPlaceholder(),
          ),
          const SizedBox(width: 12),
          // Title + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  artist,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Progress bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 4,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOut,
                          height: 4,
                          width: constraints.maxWidth * barFraction,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: rank == 1
                                  ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                                  : [Colors.cyanAccent, Colors.blueAccent],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Play count
          Text(
            '$plays\nlượt',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2035), Color(0xFF2D3054)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note_rounded, color: Colors.cyanAccent, size: 20),
    );
  }
}

class _ArtistChip extends StatelessWidget {
  final int rank;
  final String name;
  final int plays;

  const _ArtistChip({required this.rank, required this.name, required this.plays});

  @override
  Widget build(BuildContext context) {
    final colors = [
      [const Color(0xFF00C6FF), const Color(0xFF0072FF)],
      [const Color(0xFFDA22FF), const Color(0xFF9733EE)],
      [const Color(0xFFFF8C00), const Color(0xFFF44336)],
      [const Color(0xFF11998E), const Color(0xFF38EF7D)],
      [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
    ];
    final colorPair = colors[(rank - 1) % colors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colorPair),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorPair[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('#$rank ', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
              const Icon(Icons.person_rounded, color: Colors.white, size: 14),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            '$plays lượt',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RecentHistoryTile extends StatelessWidget {
  final String title;
  final String artist;
  final String? coverUrl;
  final String date;

  const _RecentHistoryTile({
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.date,
  });

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays < 7) return '${diff.inDays} ngày trước';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: coverUrl != null && (coverUrl!.startsWith('http') || coverUrl!.startsWith('data:'))
                ? Image.network(
                    coverUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artist,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _formatDate(date),
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFF1E2035),
      ),
      child: const Icon(Icons.music_note_rounded, color: Colors.cyanAccent, size: 18),
    );
  }
}
