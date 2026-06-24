import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/song_model.dart';
import '../../domain/models/feedback_model.dart';

final adminControllerProvider = Provider((ref) => AdminController());

// Stream providers for real-time updates
final songsStreamProvider = StreamProvider<List<SongModel>>((ref) {
  final controller = ref.watch(adminControllerProvider);
  return controller.getSongsStream();
});

final feedbackStreamProvider = StreamProvider<List<FeedbackModel>>((ref) {
  final controller = ref.watch(adminControllerProvider);
  return controller.getFeedbackStream();
});

class AdminController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Song Management ---

  Stream<List<SongModel>> getSongsStream() {
    return _firestore
        .collection('songs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SongModel.fromJson(data);
      }).toList();
    });
  }

  Future<void> addSong(SongModel song) async {
    final docRef = _firestore.collection('songs').doc();
    final songWithId = song.copyWith(id: docRef.id);
    await docRef.set(songWithId.toJson());
  }

  Future<void> updateSong(SongModel song) async {
    await _firestore.collection('songs').doc(song.id).update(song.toJson());
  }

  Future<void> deleteSong(String songId) async {
    await _firestore.collection('songs').doc(songId).delete();
  }

  // --- Feedback Management ---

  Stream<List<FeedbackModel>> getFeedbackStream() {
    return _firestore
        .collection('feedbacks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return FeedbackModel.fromJson(data);
      }).toList();
    });
  }
  
  Future<void> deleteFeedback(String feedbackId) async {
    await _firestore.collection('feedbacks').doc(feedbackId).delete();
  }
}
