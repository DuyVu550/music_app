import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/album.dart';

abstract class AlbumRepository {
  Future<List<Album>> getAllAlbums();
  Stream<List<Album>> getAllAlbumsStream();
  Future<void> createAlbum(Album album);
  Future<void> updateAlbum(Album album);
  Future<void> deleteAlbum(String albumId);
}

final albumRepositoryProvider = Provider<AlbumRepository>((ref) {
  throw UnimplementedError('albumRepositoryProvider must be overridden');
});
