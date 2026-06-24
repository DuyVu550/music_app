import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;
import '../../data/datasources/audio_player_service.dart';
import '../../data/repositories/track_repository_impl.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';

final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  return TrackRepositoryImpl();
});

class PlayerNotifier extends AsyncNotifier<PlayerState> {
  bool _isPlaylistInitialized = false;

  @override
  Future<PlayerState> build() async {
    final repo = ref.watch(trackRepositoryProvider);
    final popularTracks = await repo.getPopularTracks();

    final audioService = ref.watch(audioPlayerServiceProvider);

    final posSub = audioService.positionStream.listen((position) {
      final current = state.value;
      if (current != null && current.position != position) {
        state = AsyncData(current.copyWith(position: position));
      }
    });

    final durSub = audioService.durationStream.listen((duration) {
      if (duration != null) {
        final current = state.value;
        if (current != null && current.duration != duration) {
          state = AsyncData(current.copyWith(duration: duration));
        }
      }
    });

    final stateSub = audioService.playerStateStream.listen((jaState) {
      final current = state.value;
      if (current != null) {
        final isPlaying = jaState.playing;
        if (current.isPlaying != isPlaying) {
          state = AsyncData(current.copyWith(isPlaying: isPlaying));
        }
      }
    });

    final indexSub = audioService.currentIndexStream.listen((index) {
      final current = state.value;
      if (current != null && index != null && current.playlist.isNotEmpty) {
        if (index >= 0 && index < current.playlist.length) {
          final newTrack = current.playlist[index];
          if (current.currentTrack?.id != newTrack.id) {
            state = AsyncData(current.copyWith(currentTrack: newTrack));
          }
        }
      }
    });

    ref.onDispose(() {
      posSub.cancel();
      durSub.cancel();
      stateSub.cancel();
      indexSub.cancel();
    });

    return PlayerState(
      playlist: popularTracks,
      currentTrack: popularTracks.isNotEmpty ? popularTracks.first : null,
    );
  }

  void playTrack(Track track) {
    final current = state.value;
    if (current != null) {
      int index = current.playlist.indexWhere((t) => t.id == track.id);
      List<Track> updatedPlaylist = current.playlist;
      bool playlistChanged = false;

      if (index < 0) {
        updatedPlaylist = [track, ...current.playlist];
        index = 0;
        playlistChanged = true;
      }

      state = AsyncData(current.copyWith(
        currentTrack: track,
        playlist: updatedPlaylist,
        isPlaying: true,
      ));
      
      if (!_isPlaylistInitialized || playlistChanged) {
        ref.read(audioPlayerServiceProvider).setPlaylist(updatedPlaylist, initialIndex: index);
        _isPlaylistInitialized = true;
      } else {
        ref.read(audioPlayerServiceProvider).seek(Duration.zero, index: index);
        ref.read(audioPlayerServiceProvider).resume();
      }
    }
  }

  void togglePlay() {
    final current = state.value;
    if (current != null) {
      if (current.isPlaying) {
        ref.read(audioPlayerServiceProvider).pause();
      } else {
        ref.read(audioPlayerServiceProvider).resume();
      }
    }
  }

  void nextTrack() {
    ref.read(audioPlayerServiceProvider).seekToNext();
  }

  void previousTrack() {
    ref.read(audioPlayerServiceProvider).seekToPrevious();
  }

  void updatePosition(Duration position) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(position: position));
    }
  }

  void seek(Duration position) {
    ref.read(audioPlayerServiceProvider).seek(position);
  }

  void stop() {
    final current = state.value;
    if (current != null) {
      ref.read(audioPlayerServiceProvider).stop();
      _isPlaylistInitialized = false;
      state = AsyncData(current.copyWith(
        currentTrack: null,
        isPlaying: false,
        position: Duration.zero,
      ));
    }
  }
}

final playerNotifierProvider = AsyncNotifierProvider<PlayerNotifier, PlayerState>(() {
  return PlayerNotifier();
});
