import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/main.dart';
import 'package:music_app/features/auth/domain/entities/user.dart';
import 'package:music_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:music_app/features/auth/presentation/pages/login_page.dart';
import 'package:music_app/features/auth/presentation/pages/register_page.dart';
import 'package:music_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:music_app/features/auth/presentation/pages/change_password_page.dart';
import 'package:music_app/features/auth/presentation/pages/profile_page.dart';
import 'package:music_app/features/admin/presentation/pages/admin_home_page.dart';
import 'package:music_app/features/explore/presentation/pages/home_page.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';

class FakeTrackRepository implements TrackRepository {
  final mockTrack = const Track(
    id: '1',
    title: 'Fake Track',
    artistIds: ['Artist'],
    albumId: 'Album',
    coverUrl: 'http://example.com/cover.jpg',
    url: 'http://example.com/audio.mp3',
    durationMs: 180000,
  );

  @override
  Future<List<Track>> getFeaturedTracks() async => [mockTrack];

  @override
  Future<List<Track>> getPopularTracks() async => [mockTrack];

  @override
  Future<List<Track>> getNewTracks() async => [mockTrack];

  @override
  Future<List<Track>> searchTracks(String query) async => [mockTrack];

  @override
  Future<List<Track>> getAllTracks() async => [mockTrack];
}

class FakeAuthRepository implements AuthRepository {
  User? _currentUser;
  final Map<String, User> _registeredUsers = {};

  void setupUser(User user) {
    _registeredUsers[user.email] = user;
  }

  @override
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final user = _registeredUsers[email];
    if (user != null) {
      _currentUser = user;
      return user;
    }
    throw Exception('Invalid email or password');
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final user = User(id: email, email: email, name: name, role: role);
    _registeredUsers[email] = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 10));
    _currentUser = null;
  }

  bool resetEmailSent = false;
  String? resetEmailAddress;
  String? currentPasswordMock;
  String? newPasswordMock;
  String? newNameMock;

  @override
  Future<void> updateName(String newName) async {
    await Future.delayed(const Duration(milliseconds: 10));
    newNameMock = newName;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 10));
    resetEmailSent = true;
    resetEmailAddress = email;
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 10));
    currentPasswordMock = currentPassword;
    newPasswordMock = newPassword;
  }

  @override
  Future<void> updateAvatar(String base64Image) async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  late FakeAuthRepository fakeAuthRepository;
  late FakeTrackRepository fakeTrackRepository;

  setUp(() {
    fakeAuthRepository = FakeAuthRepository();
    fakeTrackRepository = FakeTrackRepository();
  });

  group('AuthNotifier Unit Tests', () {
    test('Initial state is null when no user is logged in', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(authNotifierProvider), const AsyncValue<User?>.loading());
      
      // Wait for build to complete
      await container.read(authNotifierProvider.future);
      expect(container.read(authNotifierProvider).value, null);
    });

    test('login() updates state with user details', () async {
      final user = const User(id: '1', email: 'test@example.com', name: 'Test User', role: UserRole.user);
      fakeAuthRepository.setupUser(user);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);

      await container.read(authNotifierProvider.notifier).login('test@example.com', 'password');
      expect(container.read(authNotifierProvider).value, user);
    });

    test('register() updates state and saves user', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);

      await container.read(authNotifierProvider.notifier).register(
        'Admin User',
        'admin@example.com',
        'password',
        UserRole.admin,
      );

      final currentUser = container.read(authNotifierProvider).value;
      expect(currentUser, isNotNull);
      expect(currentUser!.email, 'admin@example.com');
      expect(currentUser.role, UserRole.admin);
    });

    test('logout() clears user session', () async {
      final user = const User(id: '1', email: 'test@example.com', name: 'Test User', role: UserRole.user);
      fakeAuthRepository.setupUser(user);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);
      await container.read(authNotifierProvider.notifier).login('test@example.com', 'password');
      expect(container.read(authNotifierProvider).value, user);

      await container.read(authNotifierProvider.notifier).logout();
      expect(container.read(authNotifierProvider).value, null);
    });

    test('sendPasswordResetEmail() calls repository', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);

      await container.read(authNotifierProvider.notifier).sendPasswordResetEmail('test@example.com');
      expect(fakeAuthRepository.resetEmailSent, isTrue);
      expect(fakeAuthRepository.resetEmailAddress, 'test@example.com');
    });

    test('changePassword() calls repository', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);

      await container.read(authNotifierProvider.notifier).changePassword('oldPass', 'newPass');
      expect(fakeAuthRepository.currentPasswordMock, 'oldPass');
      expect(fakeAuthRepository.newPasswordMock, 'newPass');
    });

    test('updateName() calls repository and updates state', () async {
      final user = const User(id: '1', email: 'test@example.com', name: 'Old Name', role: UserRole.user);
      fakeAuthRepository.setupUser(user);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeAuthRepository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.future);
      await container.read(authNotifierProvider.notifier).login('test@example.com', 'password');
      expect(container.read(authNotifierProvider).value!.name, 'Old Name');

      await container.read(authNotifierProvider.notifier).updateName('New Name');
      expect(fakeAuthRepository.newNameMock, 'New Name');
      expect(container.read(authNotifierProvider).value!.name, 'New Name');
    });
  });

  group('Auth Integration & Widget Tests', () {
    testWidgets('Should start on LoginPage when unauthenticated', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
            trackRepositoryProvider.overrideWithValue(fakeTrackRepository),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle(); // Finished build() async loading
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('Should register user successfully and navigate to HomePage', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
            trackRepositoryProvider.overrideWithValue(fakeTrackRepository),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Click navigate to Register
      await tester.tap(find.text('Đăng ký tại đây'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterPage), findsOneWidget);

      // Fill in details
      await tester.enterText(find.widgetWithText(TextFormField, 'Họ và tên'), 'Regular User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'user@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu'), 'password123');

      // Default role is USER, click Register
      await tester.tap(find.widgetWithText(ElevatedButton, 'ĐĂNG KÝ'));
      await tester.pumpAndSettle();

      // Since registration automatically logs the user in and updates the authState,
      // the app redirects them directly to HomePage.
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Login as User should navigate to HomePage', (WidgetTester tester) async {
      // Pre-setup user in fake auth repo
      const user = User(id: 'u1', email: 'user@example.com', name: 'Regular User', role: UserRole.user);
      fakeAuthRepository.setupUser(user);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
            trackRepositoryProvider.overrideWithValue(fakeTrackRepository),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter details on LoginPage
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'user@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'ĐĂNG NHẬP'));

      // Wait for login async call and transition
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Should be on HomePage
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Login as Admin should navigate to AdminHomePage', (WidgetTester tester) async {
      // Pre-setup admin in fake auth repo
      const admin = User(id: 'a1', email: 'admin@example.com', name: 'Admin User', role: UserRole.admin);
      fakeAuthRepository.setupUser(admin);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
            trackRepositoryProvider.overrideWithValue(fakeTrackRepository),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter details on LoginPage
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'admin@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'ĐĂNG NHẬP'));

      // Wait for login async call and transition
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Should be on AdminHomePage
      expect(find.byType(AdminHomePage), findsOneWidget);
    });

    testWidgets('Logout from AdminHomePage should return to LoginPage', (WidgetTester tester) async {
      // Start logged in as Admin
      const admin = User(id: 'a1', email: 'admin@example.com', name: 'Admin User', role: UserRole.admin);
      fakeAuthRepository.setupUser(admin);
      fakeAuthRepository._currentUser = admin;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
            trackRepositoryProvider.overrideWithValue(fakeTrackRepository),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we are on AdminHomePage
      expect(find.byType(AdminHomePage), findsOneWidget);

      // Tap account circle icon to open popup menu
      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      // Tap Đăng xuất popup menu item
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();

      // Tap Đăng xuất button in dialog
      await tester.tap(find.widgetWithText(TextButton, 'Đăng xuất'));
      
      // Wait for logout async call and transition
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Should return to LoginPage
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('ForgotPasswordPage UI and interaction test', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: const MaterialApp(
            home: ForgotPasswordPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordPage), findsOneWidget);
      expect(find.text('Quên Mật Khẩu'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'forgot@example.com');
      await tester.tap(find.text('GỬI EMAIL'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(fakeAuthRepository.resetEmailSent, isTrue);
      expect(fakeAuthRepository.resetEmailAddress, 'forgot@example.com');
    });

    testWidgets('ChangePasswordPage UI and interaction test', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: const MaterialApp(
            home: ChangePasswordPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ChangePasswordPage), findsOneWidget);
      expect(find.text('Đổi Mật Khẩu'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu hiện tại'), 'old_pass');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mật khẩu mới'), 'new_pass_123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Xác nhận mật khẩu mới'), 'new_pass_123');

      await tester.tap(find.text('LƯU THAY ĐỔI'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(fakeAuthRepository.currentPasswordMock, 'old_pass');
      expect(fakeAuthRepository.newPasswordMock, 'new_pass_123');
    });

    testWidgets('ProfilePage UI and name update interaction test', (WidgetTester tester) async {
      final user = const User(id: '1', email: 'profile@example.com', name: 'Profile Name', role: UserRole.user);
      fakeAuthRepository.setupUser(user);
      fakeAuthRepository._currentUser = user;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(fakeAuthRepository),
          ],
          child: const MaterialApp(
            home: ProfilePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('Profile Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Họ và tên'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'Họ và tên'), 'Updated Profile Name');
      await tester.tap(find.text('LƯU THAY ĐỔI'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(fakeAuthRepository.newNameMock, 'Updated Profile Name');
    });
  });
}
