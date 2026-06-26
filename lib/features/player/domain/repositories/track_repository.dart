import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/track_repository_impl.dart';
import '../entities/track.dart';
import '../../../explore/domain/entities/category.dart';
import '../../../explore/domain/entities/artist.dart';
final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  return TrackRepositoryImpl();
});

abstract class TrackRepository {
  Future<List<Track>> getPopularTracks();
  Stream<List<Track>> getPopularTracksStream();
  Future<List<Track>> getNewTracks();
  Future<List<Track>> getFeaturedTracks();
  Future<List<Track>> searchTracks(String query);
  Future<List<Track>> getAllTracks();
  Stream<List<Track>> getAllTracksStream();
  
  // Category & Artist
  Future<List<Category>> getCategories();
  Future<List<Artist>> getArtists();
  Future<List<Track>> getTracksByCategory(String categoryId);
  Future<List<Track>> getTracksByArtist(String artistId);
}
