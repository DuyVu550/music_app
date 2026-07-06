import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/main.dart';
import 'package:music_app/features/auth/domain/entities/user.dart';
import 'package:music_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import 'package:music_app/features/explore/domain/entities/category.dart';
import 'package:music_app/features/explore/domain/entities/artist.dart';

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
  Stream<List<Track>> getPopularTracksStream() => Stream.value([mockTrack]);

  @override
  Future<List<Track>> getNewTracks() async => [mockTrack];

  @override
  Future<List<Track>> searchTracks(String query) async => [mockTrack];

  @override
  Future<List<Track>> getAllTracks() async => [mockTrack];

  @override
  Stream<List<Track>> getAllTracksStream() => Stream.value([mockTrack]);

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<List<Artist>> getArtists() async => [];

  @override
  Future<List<Track>> getTracksByCategory(String categoryId) async => [];

  @override
  Future<List<Track>> getTracksByArtist(String artistId) async => [];

  @override
  Future<void> incrementListeners(String trackId) async {}

  @override
  Future<void> recordListeningHistory(String userId, Track track) async {}

  @override
  Future<List<Map<String, dynamic>>> getListeningHistory(String userId) async => [];
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<User?> getCurrentUser() async => const User(
    id: '1',
    email: 'test@example.com',
    name: 'Test User',
    role: UserRole.user,
  );

  @override
  Future<User> login({required String email, required String password}) async =>
      getCurrentUser().then((u) => u!);

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async => getCurrentUser().then((u) => u!);

  @override
  Future<void> logout() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {}

  @override
  Future<void> updateName(String newName) async {}

  @override
  Future<void> updateAvatar(String base64Image) async {}
}

void main() {
  testWidgets('App smoke test - verifies home page title', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          trackRepositoryProvider.overrideWithValue(FakeTrackRepository()),
        ],
        child: const MyApp(),
      ),
    );

    // Let it render
    await tester.pumpAndSettle();

    // Verify that the title 'Harmonix' is displayed on the HomePage.
    expect(find.text('Harmonix'), findsOneWidget);
  });
}
