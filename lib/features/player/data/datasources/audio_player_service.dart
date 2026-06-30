// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/player_loop_mode.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  ConcatenatingAudioSource? _playlist;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<SequenceState?> get sequenceStateStream => _audioPlayer.sequenceStateStream;
  Stream<bool> get shuffleModeEnabledStream => _audioPlayer.shuffleModeEnabledStream;
  Stream<LoopMode> get loopModeStream => _audioPlayer.loopModeStream;

  AudioSource _createAudioSource(Track track) {
    return AudioSource.uri(
      Uri.parse(track.url),
      tag: MediaItem(
        id: track.id,
        album: track.albumId,
        title: track.title,
        artist: track.artistIds.isNotEmpty ? track.artistIds.first : 'Unknown Artist',
        artUri: !kIsWeb && track.coverUrl != null && track.coverUrl!.startsWith('http') 
            ? Uri.parse(track.coverUrl!) 
            : null,
      ),
    );
  }

  Future<void> setPlaylist(List<Track> tracks, {int initialIndex = 0}) async {
    try {
      final audioSources = tracks.map((track) => _createAudioSource(track)).toList();
      
      _playlist = ConcatenatingAudioSource(children: audioSources);
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(
        _playlist!,
        initialIndex: initialIndex,
      );
      await _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing audio playlist: $e");
    }
  }

  int getTrackIndexInPlaylist(String trackId) {
    if (_playlist == null) return -1;
    final sequence = _playlist!.sequence;
    for (int i = 0; i < sequence.length; i++) {
      final tag = sequence[i].tag;
      if (tag is MediaItem && tag.id == trackId) {
        return i;
      }
    }
    return -1;
  }

  void playNext(Track track) {
    if (_playlist == null) {
      setPlaylist([track]);
      return;
    }
    final currentIndex = _audioPlayer.currentIndex ?? -1;
    final targetIndex = currentIndex >= 0 ? currentIndex + 1 : 0;
    
    final existingIndex = getTrackIndexInPlaylist(track.id);
    if (existingIndex >= 0) {
      if (existingIndex == targetIndex || existingIndex == targetIndex - 1) return;
      _playlist!.removeAt(existingIndex);
      int insertPos = targetIndex;
      if (existingIndex < targetIndex) {
        insertPos--;
      }
      _playlist!.insert(insertPos, _createAudioSource(track));
    } else {
      _playlist!.insert(targetIndex, _createAudioSource(track));
    }
  }

  void addToQueue(Track track) {
    if (_playlist == null) {
      setPlaylist([track]);
      return;
    }
    final existingIndex = getTrackIndexInPlaylist(track.id);
    if (existingIndex >= 0) {
      _playlist!.removeAt(existingIndex);
    }
    _playlist!.add(_createAudioSource(track));
  }

  void removeFromQueue(String trackId) {
    if (_playlist == null) return;
    final index = getTrackIndexInPlaylist(trackId);
    if (index >= 0) {
      final currentIndex = _audioPlayer.currentIndex ?? -1;
      if (index == currentIndex) {
        seekToNext();
      }
      _playlist!.removeAt(index);
    }
  }

  void resume() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position, {int? index}) {
    _audioPlayer.seek(position, index: index);
  }

  void seekToNext() {
    _audioPlayer.seekToNext();
  }

  void seekToPrevious() {
    _audioPlayer.seekToPrevious();
  }

  void setShuffleModeEnabled(bool enabled) {
    _audioPlayer.setShuffleModeEnabled(enabled);
  }

  void setLoopMode(PlayerLoopMode mode) {
    LoopMode jaMode;
    switch (mode) {
      case PlayerLoopMode.off:
        jaMode = LoopMode.off;
        break;
      case PlayerLoopMode.all:
        jaMode = LoopMode.all;
        break;
      case PlayerLoopMode.one:
        jaMode = LoopMode.one;
        break;
    }
    _audioPlayer.setLoopMode(jaMode);
  }

  void stop() {
    _audioPlayer.stop();
    _playlist = null;
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
