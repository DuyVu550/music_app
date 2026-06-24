import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return userModel.toDomain();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      return userModel.toDomain();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel?.toDomain();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('Lỗi hệ thống: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('Lỗi đổi mật khẩu: ${e.toString()}');
    }
  }

  @override
  Future<void> updateName(String newName) async {
    try {
      await remoteDataSource.updateName(newName);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('Lỗi cập nhật tên: ${e.toString()}');
    }
  }

  @override
  Future<void> updateAvatar(String base64Image) async {
    try {
      await remoteDataSource.updateAvatar(base64Image);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('Lỗi cập nhật ảnh đại diện: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  Exception _handleFirebaseError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found for that email.');
      case 'wrong-password':
        return Exception('Wrong password provided for that user.');
      case 'email-already-in-use':
        return Exception('The account already exists for that email.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      default:
        return Exception(e.message ?? 'An unknown authentication error occurred.');
    }
  }
}
