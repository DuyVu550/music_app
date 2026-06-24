import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Dependency Injection Providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<User?> {
  late final AuthRepository _repository;

  @override
  Future<User?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    return await _repository.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password, UserRole role) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
  Future<void> sendPasswordResetEmail(String email) async {
    // Keep current state, just call the repo
    await _repository.sendPasswordResetEmail(email);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    // Don't change state to loading to avoid full rebuilds, but throw if error
    await _repository.changePassword(currentPassword, newPassword);
  }

  Future<void> updateName(String newName) async {
    final currentUser = state.value;
    if (currentUser == null) throw Exception('Không tìm thấy thông tin người dùng.');
    
    await _repository.updateName(newName);
    state = AsyncValue.data(currentUser.copyWith(name: newName));
  }

  Future<void> updateAvatar() async {
    final currentUser = state.value;
    if (currentUser == null) throw Exception('Không tìm thấy thông tin người dùng.');

    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 256,
      maxHeight: 256,
      imageQuality: 50,
    );

    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    final base64String = base64Encode(bytes);
    
    await _repository.updateAvatar(base64String);
    state = AsyncValue.data(currentUser.copyWith(photoUrl: base64String));
  }
}
