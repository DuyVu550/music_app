import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/song_model.dart';
import '../../domain/models/feedback_model.dart';
import '../../../explore/domain/entities/category.dart';
import '../../../explore/domain/entities/artist.dart';

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

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final controller = ref.watch(adminControllerProvider);
  return controller.getCategoriesStream();
});

final artistsStreamProvider = StreamProvider<List<Artist>>((ref) {
  final controller = ref.watch(adminControllerProvider);
  return controller.getArtistsStream();
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

  // --- Category Management ---

  Stream<List<Category>> getCategoriesStream() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Category.fromJson(data);
      }).toList();
    });
  }

  Future<void> addCategory(Category category) async {
    final docRef = _firestore.collection('categories').doc();
    final catWithId = category.copyWith(id: docRef.id);
    await docRef.set(catWithId.toJson());
  }

  Future<void> updateCategory(Category category) async {
    await _firestore.collection('categories').doc(category.id).set(category.toJson());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }

  // --- Artist Management ---

  Stream<List<Artist>> getArtistsStream() {
    final controller = StreamController<List<Artist>>();
    
    StreamSubscription? subSongs;
    StreamSubscription? subArtists;
    
    Future<void> update() async {
      if (controller.isClosed) return;
      try {
        final list = await _getMergedArtists();
        if (!controller.isClosed) {
          controller.add(list);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    }
    
    subSongs = _firestore.collection('songs').snapshots().listen((_) => update());
    subArtists = _firestore.collection('artists').snapshots().listen((_) => update());
    
    controller.onCancel = () {
      subSongs?.cancel();
      subArtists?.cancel();
    };
    
    // Initial fetch
    update();
    
    return controller.stream;
  }

  Future<List<Artist>> _getMergedArtists() async {
    final songsSnapshot = await _firestore.collection('songs').get().timeout(const Duration(seconds: 3));
    final artistNames = <String>{};
    for (var doc in songsSnapshot.docs) {
      final data = doc.data();
      final artistName = data['artist']?.toString();
      if (artistName != null && artistName.isNotEmpty) {
        artistNames.add(artistName.trim());
      }
    }
    
    // Include some standard default artists to match base catalog if empty
    final staticArtistNames = ['Ed Sheeran', 'Sơn Tùng M-TP', 'Đen Vâu', 'Taylor Swift', 'Charlie Puth', 'Billie Eilish'];
    artistNames.addAll(staticArtistNames);
    
    final artistsSnapshot = await _firestore.collection('artists').get().timeout(const Duration(seconds: 3));
    final Map<String, Artist> firestoreArtists = {
      for (var doc in artistsSnapshot.docs)
        doc.id: Artist.fromJson({...doc.data(), 'id': doc.id})
    };
    
    final List<Artist> merged = [];
    for (final name in artistNames) {
      final id = 'artist_${name.replaceAll(' ', '_')}';
      if (firestoreArtists.containsKey(id)) {
        merged.add(firestoreArtists[id]!);
      } else {
        merged.add(Artist(
          id: id,
          name: name,
          imageUrl: 'https://picsum.photos/seed/${name.hashCode.abs()}/300/300',
        ));
      }
    }
    return merged;
  }

  Future<void> addArtist(Artist artist) async {
    final docRef = _firestore.collection('artists').doc();
    final artistWithId = artist.copyWith(id: docRef.id);
    await docRef.set(artistWithId.toJson());
  }

  Future<void> updateArtist(Artist artist) async {
    await _firestore.collection('artists').doc(artist.id).set(artist.toJson());
  }

  Future<void> deleteArtist(String artistId) async {
    await _firestore.collection('artists').doc(artistId).delete();
  }
}
