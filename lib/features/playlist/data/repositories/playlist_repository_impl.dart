import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/repositories/playlist_repository.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl();
});

class PlaylistRepositoryImpl implements PlaylistRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Playlist>> getUserPlaylistsStream(String userId) {
    return _firestore
        .collection('playlists')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          if (data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          } else if (data['createdAt'] == null) {
            data['createdAt'] = DateTime.now().toIso8601String();
          }
          return Playlist.fromJson(data);
        } catch (e) {
          return null;
        }
      }).whereType<Playlist>().toList();

      list.sort((a, b) {
        final aTime = a.createdAt ?? '';
        final bTime = b.createdAt ?? '';
        return bTime.compareTo(aTime);
      });
      return list;
    });
  }

  @override
  Future<void> createPlaylist(Playlist playlist) async {
    final docRef = _firestore.collection('playlists').doc();
    final playlistData = playlist.copyWith(id: docRef.id).toJson();
    playlistData['createdAt'] = FieldValue.serverTimestamp();
    await docRef.set(playlistData);
  }

  @override
  Future<void> updatePlaylist(Playlist playlist) async {
    await _firestore.collection('playlists').doc(playlist.id).update({
      'name': playlist.name,
      'description': playlist.description,
      'coverUrl': playlist.coverUrl,
    });
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    await _firestore.collection('playlists').doc(playlistId).delete();
  }

  @override
  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final docRef = _firestore.collection('playlists').doc(playlistId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final data = snapshot.data() ?? {};
      final trackIds = List<String>.from(data['trackIds'] ?? []);
      if (!trackIds.contains(trackId)) {
        trackIds.add(trackId);
        transaction.update(docRef, {'trackIds': trackIds});
      }
    });
  }

  @override
  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    final docRef = _firestore.collection('playlists').doc(playlistId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final data = snapshot.data() ?? {};
      final trackIds = List<String>.from(data['trackIds'] ?? []);
      if (trackIds.contains(trackId)) {
        trackIds.remove(trackId);
        transaction.update(docRef, {'trackIds': trackIds});
      }
    });
  }
}
