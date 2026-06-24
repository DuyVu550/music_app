import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/track_repository_impl.dart';
import '../entities/track.dart';

final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  return TrackRepositoryImpl();
});

abstract class TrackRepository {
  Future<List<Track>> getPopularTracks();
  Future<List<Track>> getNewTracks();
  Future<List<Track>> getFeaturedTracks();
  Future<List<Track>> searchTracks(String query);
  Future<List<Track>> getAllTracks();
}
