import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import '../../../player/domain/entities/track.dart';
import '../../../player/presentation/controllers/player_notifier.dart';
import '../controllers/featured_tracks_notifier.dart';
import '../controllers/popular_tracks_notifier.dart';
import '../controllers/new_tracks_notifier.dart';
import '../controllers/categories_notifier.dart';
import '../controllers/artists_notifier.dart';
import 'category_songs_page.dart';
import 'artist_songs_page.dart';
import 'feedback_page.dart';
import 'all_songs_page.dart';
import 'featured_songs_page.dart';
import 'popular_songs_page.dart';
import 'new_songs_page.dart';
import 'category_list_page.dart';
import 'artist_list_page.dart';
import '../../../../core/utils/format_utils.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../../auth/presentation/pages/change_password_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../../player/presentation/widgets/song_options_bottom_sheet.dart';
import 'package:music_app/features/favorites/presentation/pages/favorite_songs_page.dart';
import 'package:music_app/features/playlist/presentation/pages/my_playlists_page.dart';
import '../../../player/presentation/pages/downloaded_tracks_page.dart';
import 'music_wrapped_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  Timer? _sliderTimer;
  int _currentPage = 0;
  int _sliderItemCount = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  Future<List<Track>>? _searchFuture;

  void _startAutoSlide(int itemCount) {
    if (_sliderItemCount == itemCount && _sliderTimer != null && _sliderTimer!.isActive) {
      return; // Timer đang chạy bình thường, không reset lại
    }
    _sliderItemCount = itemCount;
    _sliderTimer?.cancel();
    if (itemCount <= 1) return;
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % itemCount;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _debounce?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        title: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).logout();
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featuredAsync = ref.watch(featuredTracksProvider);
    final popularAsync = ref.watch(popularTracksProvider);
    final newTracksAsync = ref.watch(newTracksProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final artistsAsync = ref.watch(artistsProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      drawer: Drawer(
        backgroundColor: const Color(0xFF16162A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0F0F1E)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (user != null && user.photoUrl != null && user.photoUrl!.isNotEmpty)
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: MemoryImage(base64Decode(user.photoUrl!)),
                    )
                  else
                    Image.asset('assets/images/logo.png', width: 60, height: 60),
                  const SizedBox(height: 12),
                  Text(user?.name ?? 'Harmonix Music', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_filled, color: Colors.cyanAccent),
              title: const Text('Trang chủ', style: TextStyle(color: Colors.white)),
              onTap: () {
                FocusScope.of(context).unfocus();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_music_rounded, color: Colors.white70),
              title: const Text('Tất cả bài hát', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllSongsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rounded, color: Colors.orangeAccent),
              title: const Text('Bài hát nổi bật', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FeaturedSongsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up_rounded, color: Colors.pinkAccent),
              title: const Text('Bài hát phổ biến', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PopularSongsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.new_releases_rounded, color: Colors.greenAccent),
              title: const Text('Bài hát mới nhất', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NewSongsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
              title: const Text('Bài hát yêu thích', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoriteSongsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music_rounded, color: Colors.cyanAccent),
              title: const Text('Playlist của tôi', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPlaylistsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.download_for_offline_rounded, color: Colors.cyanAccent),
              title: const Text('Nhạc đã tải offline', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DownloadedTracksPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_rounded, color: Colors.cyanAccent),
              title: const Text('Thống kê âm nhạc', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MusicWrappedPage()));
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.person_rounded, color: Colors.cyanAccent),
              title: const Text('Thông tin cá nhân', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.password_rounded, color: Colors.cyanAccent),
              title: const Text('Đổi mật khẩu', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context, ref);
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (ctx) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Scaffold.of(ctx).openDrawer();
                            },
                          ),
                        ),
                        Image.asset(
                          'assets/images/logo.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Harmonix',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.feedback_outlined, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FeedbackPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                      
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        if (val.trim().isNotEmpty) {
                          setState(() {
                            _searchFuture = ref.read(trackRepositoryProvider).searchTracks(val.trim());
                          });
                        }
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tên bài hát...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Conditional Results if Searching
              if (_searchQuery.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Kết quả tìm kiếm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                FutureBuilder<List<Track>>(
                  future: _searchFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(color: Colors.cyanAccent),
                        ),
                      );
                    }
                    final results = snapshot.data ?? [];
                    if (results.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Không tìm thấy bài hát nào.', style: TextStyle(color: Colors.white70)),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final track = results[index];
                        return _buildSongTile(ref, track);
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ] else ...[
                // ============================================================
                // FEATURED TRACKS SLIDER
                // ============================================================
                _buildFeaturedSlider(featuredAsync),
                const SizedBox(height: 24),

                // ============================================================
                // CATEGORIES (Thể loại)
                // ============================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thể loại nổi bật',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CategoryListPage()));
                        },
                        child: const Text('Xem tất cả', style: TextStyle(color: Colors.cyanAccent)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: categoriesAsync.when(
                    data: (categories) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CategorySongsPage(category: category)));
                            },
                            child: Container(
                              width: 140,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(category.imageUrl),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                category.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
                    error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red))),
                  ),
                ),
                const SizedBox(height: 24),

                // ============================================================
                // ARTISTS (Nghệ sĩ)
                // ============================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nghệ sĩ nổi bật',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ArtistListPage()));
                        },
                        child: const Text('Xem tất cả', style: TextStyle(color: Colors.cyanAccent)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: artistsAsync.when(
                    data: (artists) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        itemCount: artists.length,
                        itemBuilder: (context, index) {
                          final artist = artists[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistSongsPage(artist: artist)));
                            },
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage: NetworkImage(artist.imageUrl),
                                    backgroundColor: Colors.white24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    artist.name,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
                    error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red))),
                  ),
                ),
                const SizedBox(height: 24),


                // Popular Section (Realtime-like from provider state)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Phổ Biến',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PopularSongsPage()));
                        },
                        child: const Text('Xem tất cả', style: TextStyle(color: Colors.cyanAccent)),
                      ),
                    ],
                  ),
                ),
                popularAsync.when(
                  data: (tracks) {
                    if (tracks.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Không có bài hát phổ biến', style: TextStyle(color: Colors.white70)),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return _buildSongTile(ref, track);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Colors.cyanAccent),
                    ),
                  ),
                  error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red))),
                ),
                const SizedBox(height: 20),

                // New Released Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bài hát mới nhất',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const NewSongsPage()));
                        },
                        child: const Text('Xem tất cả', style: TextStyle(color: Colors.cyanAccent)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                newTracksAsync.when(
                  data: (tracks) {
                    if (tracks.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Không có bài hát mới', style: TextStyle(color: Colors.white70)),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return _buildSongTile(ref, track);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Colors.cyanAccent),
                    ),
                  ),
                  error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.red))),
                ),
                const SizedBox(height: 100), // Space for bottom player
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ==========================================================================
  // WIDGET: Featured Tracks Slider — Hiển thị ảnh bìa + Auto Run (Realtime)
  // ==========================================================================
  Widget _buildFeaturedSlider(AsyncValue<List<Track>> featuredAsync) {
    return featuredAsync.when(
      data: (tracks) {
        if (tracks.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text('Không có bài hát nổi bật', style: TextStyle(color: Colors.white54)),
            ),
          );
        }

        // Khởi động auto-slide sau khi dữ liệu đã sẵn sàng
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAutoSlide(tracks.length);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Nổi Bật',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Slider ảnh bìa bài hát nổi bật
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: tracks.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  final hasImage = track.coverUrl != null && track.coverUrl!.isNotEmpty;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Ảnh bìa từ Last.fm hoặc ảnh mặc định
                          hasImage
                              ? Image.network(
                                  track.coverUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/album_placeholder.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/images/album_placeholder.png',
                                  fit: BoxFit.cover,
                                ),

                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.75),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),

                          // Thông tin bài hát
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  track.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(blurRadius: 8, color: Colors.black54),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  track.artistIds.isNotEmpty ? track.artistIds.first : 'Unknown Artist',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    shadows: const [
                                      Shadow(blurRadius: 8, color: Colors.black54),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Nút Play ở góc phải
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: () {
                                ref.read(playerNotifierProvider.notifier).playTrack(track);
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 26),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                tracks.length > 10 ? 10 : tracks.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.cyanAccent : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      ),
      error: (err, stack) => SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white38, size: 40),
              const SizedBox(height: 8),
              Text('Không thể tải: $err', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSongTile(WidgetRef ref, Track track) {
    final hasNetworkImage = track.coverUrl != null &&
        track.coverUrl!.isNotEmpty &&
        track.coverUrl!.startsWith('http');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hasNetworkImage
                ? Image.network(
                    track.coverUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/album_placeholder.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/album_placeholder.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
          ),
        title: Text(
          track.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                track.artistIds.isNotEmpty ? track.artistIds.first : 'Unknown Artist',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.headset_rounded, size: 12, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(width: 4),
            Text(
              FormatUtils.formatListeners(track.listeners),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FavoriteButton(trackId: track.id, size: 20),
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
        },
      ),
    ),
  );
}
}
