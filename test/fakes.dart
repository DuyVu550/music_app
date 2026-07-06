import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/favorites/data/repositories/favorite_repository.dart';
import 'package:music_app/features/favorites/domain/models/favorite_model.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:music_app/features/auth/domain/entities/user.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/explore/domain/entities/category.dart';
import 'package:music_app/features/explore/domain/entities/artist.dart';

class FakeFavoriteRepository implements FavoriteRepository {
  List<FavoriteModel> mockFavorites = [];
  
  @override
  Stream<List<FavoriteModel>> getFavoritesStream(String userId) {
    return Stream.value(mockFavorites);
  }
  
  @override
  Future<void> toggleFavorite(String userId, String trackId, bool isFavorite) async {
    // Fake implementation
  }
}

class FakeAuthNotifier extends AsyncNotifier<User?> implements AuthNotifier {
  @override
  Future<User?> build() async => const User(id: 'test_uid', name: 'Test', email: 'test@test.com', role: UserRole.user);
  
  @override
  Future<void> updateName(String name) async {}
  @override
  Future<void> updateAvatar() async {}
  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {}
  @override
  Future<void> login(String email, String password) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> register(String name, String email, String password, UserRole role) async {}
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}

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
