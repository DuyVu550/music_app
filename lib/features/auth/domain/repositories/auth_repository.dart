import '../entities/user.dart';

abstract class AuthRepository {
  /// Sign in with email and password.
  Future<User> login({
    required String email,
    required String password,
  });

  /// Register a new user.
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  /// Get current signed in user.
  Future<User?> getCurrentUser();

  Future<void> sendPasswordResetEmail(String email);
  
  Future<void> changePassword(String currentPassword, String newPassword);

  Future<void> updateName(String newName);
  
  Future<void> updateAvatar(String base64Image);

  /// Sign out.
  Future<void> logout();
}
