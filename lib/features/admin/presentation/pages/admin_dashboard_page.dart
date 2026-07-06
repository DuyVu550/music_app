import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../player/domain/repositories/track_repository.dart';
import '../../../player/domain/entities/track.dart';

// Provider to fetch dashboard stats
final dashboardStatsProvider = FutureProvider<_DashboardStats>((ref) async {
  final firestore = FirebaseFirestore.instance;

  // Fetch counts in parallel
  final results = await Future.wait([
    firestore.collection('songs').count().get(),
    firestore.collection('users').count().get(),
    // Artists and categories are stored inside songs, we approximate via tracks
  ]);

  final totalSongs = results[0].count ?? 0;
  final totalUsers = results[1].count ?? 0;

  // Top songs from track repository (sorted by listeners)
  final repo = ref.read(trackRepositoryProvider);
  final allTracks = await repo.getAllTracks();
  allTracks.sort((a, b) => b.listeners.compareTo(a.listeners));
  final topTracks = allTracks.take(5).toList();

  // Count unique artists and categories from tracks
  final artistSet = <String>{};
  final categorySet = <String>{};
  for (final t in allTracks) {
    artistSet.addAll(t.artistIds);
    if (t.categoryIds != null) categorySet.addAll(t.categoryIds!);
  }

  return _DashboardStats(
    totalSongs: totalSongs,
    totalUsers: totalUsers,
    totalArtists: artistSet.length,
    totalCategories: categorySet.length,
    topTracks: topTracks,
  );
});

class _DashboardStats {
  final int totalSongs;
  final int totalUsers;
  final int totalArtists;
  final int totalCategories;
  final List<Track> topTracks;

  const _DashboardStats({
    required this.totalSongs,
    required this.totalUsers,
    required this.totalArtists,
    required this.totalCategories,
    required this.topTracks,
  });
}

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.cyanAccent),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text('Lỗi tải dữ liệu:\n$e',
                style: const TextStyle(color: Colors.white54),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(dashboardStatsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black),
            ),
          ],
        ),
      ),
      data: (stats) => RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardStatsProvider),
        color: Colors.cyanAccent,
        backgroundColor: const Color(0xFF0F2027),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.dashboard_rounded,
                        color: Colors.cyanAccent, size: 36),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng quan hệ thống',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Cập nhật theo thời gian thực',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StatCard(
                    icon: Icons.library_music_rounded,
                    label: 'Bài hát',
                    value: stats.totalSongs.toString(),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    ),
                  ),
                  _StatCard(
                    icon: Icons.people_rounded,
                    label: 'Người dùng',
                    value: stats.totalUsers.toString(),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDA22FF), Color(0xFF9733EE)],
                    ),
                  ),
                  _StatCard(
                    icon: Icons.person_rounded,
                    label: 'Nghệ sĩ',
                    value: stats.totalArtists.toString(),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8C00), Color(0xFFF44336)],
                    ),
                  ),
                  _StatCard(
                    icon: Icons.category_rounded,
                    label: 'Thể loại',
                    value: stats.totalCategories.toString(),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Top songs section
              Row(
                children: [
                  const Icon(Icons.leaderboard_rounded,
                      color: Colors.cyanAccent, size: 22),
                  const SizedBox(width: 10),
                  const Text(
                    'Top bài hát được nghe nhiều nhất',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (stats.topTracks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Chưa có dữ liệu lượt nghe',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                  ),
                )
              else
                ...stats.topTracks.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final track = entry.value;
                  final maxListeners = stats.topTracks.first.listeners;
                  return _TopSongRow(
                    rank: rank,
                    track: track,
                    maxListeners: maxListeners > 0 ? maxListeners : 1,
                  );
                }),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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
            color: gradient.colors.first.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 26),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopSongRow extends StatelessWidget {
  final int rank;
  final Track track;
  final int maxListeners;

  const _TopSongRow({
    required this.rank,
    required this.track,
    required this.maxListeners,
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
    final barFraction = track.listeners / maxListeners;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rank == 1
              ? const Color(0xFFFFD700).withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: track.coverUrl != null &&
                    track.coverUrl!.startsWith('http')
                ? Image.network(
                    track.coverUrl!,
                    width: 44,
                    height: 44,
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
                  track.title,
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
                  track.artistIds.isNotEmpty
                      ? track.artistIds.first
                      : 'Unknown',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      Container(
                        height: 4,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Container(
                        height: 4,
                        width: constraints.maxWidth * barFraction,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: rank == 1
                                ? [
                                    const Color(0xFFFFD700),
                                    const Color(0xFFFFA500)
                                  ]
                                : [Colors.cyanAccent, Colors.blueAccent],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              const Icon(Icons.headphones_rounded,
                  color: Colors.cyanAccent, size: 14),
              const SizedBox(height: 2),
              Text(
                '${track.listeners}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2035), Color(0xFF2D3054)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note_rounded,
          color: Colors.cyanAccent, size: 20),
    );
  }
}
