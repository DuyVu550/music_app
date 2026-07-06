import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../../auth/presentation/pages/change_password_page.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import 'admin_dashboard_page.dart';
import 'song_management_page.dart';
import 'category_management_page.dart';
import 'artist_management_page.dart';
import 'feedback_management_page.dart';
import 'album_management_page.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AdminDashboardPage(),
    SongManagementPage(),
    CategoryManagementPage(),
    ArtistManagementPage(),
    AlbumManagementPage(),
    FeedbackManagementPage(),
  ];

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Quản lý Bài hát';
      case 2:
        return 'Quản lý Thể loại';
      case 3:
        return 'Quản lý Nghệ sĩ';
      case 4:
        return 'Quản lý Album';
      case 5:
        return 'Phản hồi từ Người dùng';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)),
        backgroundColor: const Color(0xFF0F2027),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: user != null && user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: MemoryImage(base64Decode(user.photoUrl!)),
                  )
                : const Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              } else if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                );
              } else if (value == 'logout') {
                _showLogoutDialog(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Thông tin cá nhân'),
              ),
              const PopupMenuItem(
                value: 'change_password',
                child: Text('Đổi mật khẩu'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0F2027),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white54,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music_rounded),
            label: 'Bài hát',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_rounded),
            label: 'Thể loại',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded),
            label: 'Nghệ sĩ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.album_rounded),
            label: 'Album',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback_rounded),
            label: 'Phản hồi',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203A43),
        title: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?',
            style: TextStyle(color: Colors.white70)),
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
}
