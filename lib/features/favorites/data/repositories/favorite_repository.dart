import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/favorite_model.dart';

final favoriteRepositoryProvider = Provider((ref) => FavoriteRepository());

class FavoriteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách yêu thích của một user theo thời gian thực (Real-time)
  Stream<List<FavoriteModel>> getFavoritesStream(String userId) {
    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        // Fix Timestamp conversion for createdAt
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return FavoriteModel.fromJson(data);
      }).toList();
    });
  }

  // Thêm hoặc Xóa bài hát khỏi danh sách yêu thích
  Future<void> toggleFavorite(String userId, String trackId, bool isFavorite) async {
    final querySnapshot = await _firestore
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .where('trackId', isEqualTo: trackId)
        .get();

    if (isFavorite) {
      // Nếu chưa có thì thêm vào
      if (querySnapshot.docs.isEmpty) {
        final docRef = _firestore.collection('favorites').doc();
        await docRef.set({
          'userId': userId,
          'trackId': trackId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } else {
      // Nếu có rồi thì xóa đi
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }
}
