import '../entities/track.dart';

abstract class TrackRepository {
  Future<List<Track>> getPopularTracks();
  Future<List<Track>> getNewTracks();
  Future<List<Track>> getFeaturedTracks();
  Future<List<Track>> searchTracks(String query);
  Future<List<Track>> getAllTracks();
}
