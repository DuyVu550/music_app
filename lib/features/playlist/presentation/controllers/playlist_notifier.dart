import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../domain/entities/playlist.dart';
import '../../data/repositories/playlist_repository_impl.dart';

final userPlaylistsProvider = StreamProvider<List<Playlist>>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final user = authState.value;
  if (user == null) {
    return Stream.value([]);
  }
  final repository = ref.watch(playlistRepositoryProvider);
  return repository.getUserPlaylistsStream(user.id);
});

final playlistControllerProvider = Provider((ref) {
  return PlaylistController(ref);
});

class PlaylistController {
  final Ref _ref;

  PlaylistController(this._ref);

  Future<void> createPlaylist({
    required String name,
    String? description,
    String? coverUrl,
  }) async {
    final authState = _ref.read(authNotifierProvider);
    final user = authState.value;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');

    final playlist = Playlist(
      id: '',
      name: name,
      userId: user.id,
      description: description,
      coverUrl: coverUrl,
      trackIds: [],
    );

    await _ref.read(playlistRepositoryProvider).createPlaylist(playlist);
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await _ref.read(playlistRepositoryProvider).updatePlaylist(playlist);
  }

  Future<void> deletePlaylist(String playlistId) async {
    await _ref.read(playlistRepositoryProvider).deletePlaylist(playlistId);
  }

  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    await _ref.read(playlistRepositoryProvider).addTrackToPlaylist(playlistId, trackId);
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    await _ref.read(playlistRepositoryProvider).removeTrackFromPlaylist(playlistId, trackId);
  }
}
