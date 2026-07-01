import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/audio_player_service.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/track_repository.dart';
import '../../domain/entities/player_loop_mode.dart';
import 'package:just_audio/just_audio.dart' as ja;


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

        // Fix for LoopMode.one on Web/PWA when hosted.
        // When the browser fails to loop and reaches completed state,
        // manually seek back to start and play.
        if (jaState.processingState == ja.ProcessingState.completed &&
            current.loopMode == PlayerLoopMode.one) {
          audioService.seek(Duration.zero);
          audioService.resume();
        }
      }
    });

    final indexSub = audioService.sequenceStateStream.listen((sequenceState) {
      final current = state.value;
      if (current != null && sequenceState != null) {
        final currentItem = sequenceState.currentSource?.tag;
        if (currentItem != null) {
          // just_audio uses MediaItem for the tag
          // But we don't have access to just_audio_background MediaItem directly here without importing it
          // Wait, we need to import 'package:just_audio_background/just_audio_background.dart';
          // Actually, we can just dynamic cast it if we want. Let's see if we can do currentItem.id
          final newTrackId = (currentItem as dynamic).id;
          if (current.currentTrack?.id != newTrackId) {
            // Find the track in the playlist
            try {
              final newTrack = current.playlist.firstWhere((t) => t.id == newTrackId);
              state = AsyncData(current.copyWith(currentTrack: newTrack));
            } catch (e) {
              // Not found
            }
          }
        }
      }
    });

    final shuffleSub = audioService.shuffleModeEnabledStream.listen((enabled) {
      final current = state.value;
      if (current != null && current.isShuffleModeEnabled != enabled) {
        state = AsyncData(current.copyWith(isShuffleModeEnabled: enabled));
      }
    });

    final loopSub = audioService.loopModeStream.listen((jaLoopMode) {
      final current = state.value;
      if (current != null) {
        PlayerLoopMode loopMode;
        switch (jaLoopMode) {
          case ja.LoopMode.off:
            loopMode = PlayerLoopMode.off;
            break;
          case ja.LoopMode.all:
            loopMode = PlayerLoopMode.all;
            break;
          case ja.LoopMode.one:
            loopMode = PlayerLoopMode.one;
            break;
        }
        if (current.loopMode != loopMode) {
          state = AsyncData(current.copyWith(loopMode: loopMode));
        }
      }
    });

    ref.onDispose(() {
      posSub.cancel();
      durSub.cancel();
      stateSub.cancel();
      indexSub.cancel();
      shuffleSub.cancel();
      loopSub.cancel();
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

      state = AsyncData(
        current.copyWith(
          currentTrack: track,
          playlist: updatedPlaylist,
          isPlaying: true,
        ),
      );

      if (!_isPlaylistInitialized || playlistChanged) {
        ref
            .read(audioPlayerServiceProvider)
            .setPlaylist(updatedPlaylist, initialIndex: index);
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
    final current = state.value;
    if (current != null && current.playlist.isNotEmpty) {
      final currentTrack = current.currentTrack;
      if (currentTrack != null) {
        final currentIndex = current.playlist.indexWhere((t) => t.id == currentTrack.id);
        if (currentIndex >= 0) {
          final nextIndex = (currentIndex + 1) % current.playlist.length;
          playTrack(current.playlist[nextIndex]);
        }
      }
    }
  }

  void previousTrack() {
    final current = state.value;
    if (current != null && current.playlist.isNotEmpty) {
      final currentTrack = current.currentTrack;
      if (currentTrack != null) {
        final currentIndex = current.playlist.indexWhere((t) => t.id == currentTrack.id);
        if (currentIndex >= 0) {
          final prevIndex = (currentIndex - 1 + current.playlist.length) % current.playlist.length;
          playTrack(current.playlist[prevIndex]);
        }
      }
    }
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
      state = AsyncData(
        current.copyWith(
          currentTrack: null,
          isPlaying: false,
          position: Duration.zero,
        ),
      );
    }
  }

  void playNext(Track track) {
    final current = state.value;
    if (current != null) {
      final audioService = ref.read(audioPlayerServiceProvider);
      audioService.playNext(track);

      final existingIndex = current.playlist.indexWhere((t) => t.id == track.id);
      final list = List<Track>.from(current.playlist);
      if (existingIndex >= 0) {
        list.removeAt(existingIndex);
      }
      final currentIndex = list.indexWhere((t) => t.id == current.currentTrack?.id);
      final insertPos = currentIndex >= 0 ? currentIndex + 1 : 0;
      list.insert(insertPos, track);

      state = AsyncData(current.copyWith(playlist: list));
    }
  }

  void addToQueue(Track track) {
    final current = state.value;
    if (current != null) {
      final audioService = ref.read(audioPlayerServiceProvider);
      audioService.addToQueue(track);

      final existingIndex = current.playlist.indexWhere((t) => t.id == track.id);
      final list = List<Track>.from(current.playlist);
      if (existingIndex >= 0) {
        list.removeAt(existingIndex);
      }
      list.add(track);

      state = AsyncData(current.copyWith(playlist: list));
    }
  }

  void removeFromQueue(Track track) {
    final current = state.value;
    if (current != null) {
      final audioService = ref.read(audioPlayerServiceProvider);
      audioService.removeFromQueue(track.id);

      final list = current.playlist.where((t) => t.id != track.id).toList();
      state = AsyncData(current.copyWith(
        playlist: list,
        currentTrack: current.currentTrack?.id == track.id
            ? (list.isNotEmpty ? list.first : null)
            : current.currentTrack,
      ));
    }
  }

  void toggleShuffle() {
    final current = state.value;
    if (current != null) {
      ref.read(audioPlayerServiceProvider).setShuffleModeEnabled(!current.isShuffleModeEnabled);
    }
  }

  void cycleLoopMode() {
    final current = state.value;
    if (current != null) {
      PlayerLoopMode nextMode;
      switch (current.loopMode) {
        case PlayerLoopMode.off:
          nextMode = PlayerLoopMode.all;
          break;
        case PlayerLoopMode.all:
          nextMode = PlayerLoopMode.one;
          break;
        case PlayerLoopMode.one:
          nextMode = PlayerLoopMode.off;
          break;
      }
      ref.read(audioPlayerServiceProvider).setLoopMode(nextMode);
    }
  }
}

final playerNotifierProvider =
    AsyncNotifierProvider<PlayerNotifier, PlayerState>(() {
      return PlayerNotifier();
    });
