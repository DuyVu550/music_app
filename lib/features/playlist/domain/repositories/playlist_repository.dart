import '../entities/playlist.dart';

abstract class PlaylistRepository {
  Stream<List<Playlist>> getUserPlaylistsStream(String userId);
  Future<void> createPlaylist(Playlist playlist);
  Future<void> updatePlaylist(Playlist playlist);
  Future<void> deletePlaylist(String playlistId);
  Future<void> addTrackToPlaylist(String playlistId, String trackId);
  Future<void> removeTrackFromPlaylist(String playlistId, String trackId);
}
