import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart' show UserRole;

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  Future<UserModel?> getCurrentUser();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> changePassword(String currentPassword, String newPassword);

  Future<void> updateName(String newName);

  Future<void> updateAvatar(String base64Image);

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Login failed: User is null');
      }

      // Fetch user profile from firestore
      final docSnapshot = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        throw Exception('User profile not found in database');
      }

      return UserModel.fromJson(docSnapshot.data()!..['id'] = docSnapshot.id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Registration failed: User is null');
      }

      // Save additional user info to firestore
      final userModel = UserModel(
        id: firebaseUser.uid,
        email: email,
        name: name,
        role: role,
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toJson()..remove('id')); // ID is document key

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      final docSnapshot = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null; // or throw exception depending on business logic
      }

      return UserModel.fromJson(docSnapshot.data()!..['id'] = docSnapshot.id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Bạn chưa đăng nhập.');

    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> updateName(String newName) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Bạn chưa đăng nhập.');
    await _firestore.collection('users').doc(user.uid).update({
      'name': newName,
    });
  }

  @override
  Future<void> updateAvatar(String base64Image) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('Bạn chưa đăng nhập.');
    // Update firestore
    await _firestore.collection('users').doc(user.uid).update({
      'photoUrl': base64Image,
    });
    // Update firebase auth (optional, but good for sync)
    try {
      if (base64Image.length < 2048 &&
          (base64Image.startsWith('http://') || base64Image.startsWith('https://'))) {
        await user.updatePhotoURL(base64Image);
      }
    } catch (_) {
      // Ignore firebase auth sync errors for base64 or custom URLs
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
