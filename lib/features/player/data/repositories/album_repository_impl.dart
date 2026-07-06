import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/album.dart';
import '../../domain/repositories/album_repository.dart';

final albumRepositoryImplProvider = Provider<AlbumRepository>((ref) {
  return AlbumRepositoryImpl();
});

class AlbumRepositoryImpl implements AlbumRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Album>> getAllAlbums() async {
    final snapshot = await _firestore
        .collection('albums')
        .orderBy('title')
        .get();
    return snapshot.docs.map((doc) => _fromDoc(doc)).toList();
  }

  @override
  Stream<List<Album>> getAllAlbumsStream() {
    return _firestore
        .collection('albums')
        .orderBy('title')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => _fromDoc(doc)).toList());
  }

  @override
  Future<void> createAlbum(Album album) async {
    final docRef = _firestore.collection('albums').doc();
    await docRef.set(_toJson(album.copyWith(id: docRef.id)));
  }

  @override
  Future<void> updateAlbum(Album album) async {
    await _firestore
        .collection('albums')
        .doc(album.id)
        .update(_toJson(album));
  }

  @override
  Future<void> deleteAlbum(String albumId) async {
    await _firestore.collection('albums').doc(albumId).delete();
  }

  Album _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return Album(
      id: doc.id,
      title: data['title'] as String? ?? 'Unknown Album',
      coverUrl: data['coverUrl'] as String?,
      artistIds: List<String>.from(data['artistIds'] as List? ?? []),
      releaseYear: (data['releaseYear'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> _toJson(Album album) {
    return {
      'id': album.id,
      'title': album.title,
      'coverUrl': album.coverUrl,
      'artistIds': album.artistIds,
      'releaseYear': album.releaseYear,
    };
  }
}
