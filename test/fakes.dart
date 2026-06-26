import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/favorites/data/repositories/favorite_repository.dart';
import 'package:music_app/features/favorites/domain/models/favorite_model.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:music_app/features/auth/domain/entities/user.dart';

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
