import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/favorites/data/repositories/favorite_repository.dart';
import 'package:music_app/features/favorites/domain/models/favorite_model.dart';
import 'package:music_app/features/favorites/presentation/controllers/favorite_notifier.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:music_app/features/auth/domain/entities/user.dart';
import 'dart:async';

// Fake classes
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

void main() {
  group('FavoriteNotifier Tests', () {
    late FakeFavoriteRepository mockRepo;
    late ProviderContainer container;

    setUp(() {
      mockRepo = FakeFavoriteRepository();
      
      container = ProviderContainer(
        overrides: [
          favoriteRepositoryProvider.overrideWithValue(mockRepo),
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is empty when user has no favorites', () async {
      mockRepo.mockFavorites = [];
      await container.read(authNotifierProvider.future); // Wait for auth to load
      final state = await container.read(favoriteNotifierProvider.future);
      expect(state, isEmpty);
    });

    test('Fetches favorites from repository', () async {
      final mockFavorites = [
        FavoriteModel(id: '1', userId: 'test_uid', trackId: 'track_1', createdAt: DateTime.now()),
      ];
      
      mockRepo.mockFavorites = mockFavorites;
      await container.read(authNotifierProvider.future); // Wait for auth to load

      final state = await container.read(favoriteNotifierProvider.future);
      expect(state.length, 1);
      expect(state.first.trackId, 'track_1');
    });

    test('isFavorite returns true for existing track', () async {
      final mockFavorites = [
        FavoriteModel(id: '1', userId: 'test_uid', trackId: 'track_1', createdAt: DateTime.now()),
      ];
      
      mockRepo.mockFavorites = mockFavorites;
      await container.read(authNotifierProvider.future); // Wait for auth to load

      await container.read(favoriteNotifierProvider.future);
      
      final notifier = container.read(favoriteNotifierProvider.notifier);
      expect(notifier.isFavorite('track_1'), isTrue);
      expect(notifier.isFavorite('track_2'), isFalse);
    });
  });
}
