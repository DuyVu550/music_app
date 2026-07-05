import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';

class CommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Comment>> getCommentsStream(String songId) {
    return _firestore
        .collection('songs')
        .doc(songId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Comment.fromJson(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> addComment(String songId, Comment comment) async {
    await _firestore
        .collection('songs')
        .doc(songId)
        .collection('comments')
        .add(comment.toJson());
  }

  Future<void> deleteComment(String songId, String commentId) async {
    await _firestore
        .collection('songs')
        .doc(songId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }
}

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});
