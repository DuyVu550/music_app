// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/track.dart';
import '../../domain/entities/player_loop_mode.dart';
import 'offline_track_service.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final offlineService = ref.read(offlineTrackServiceProvider);
  final service = AudioPlayerService(offlineService: offlineService);
  ref.onDispose(() => service.dispose());
  return service;
});

class AudioPlayerService {
  late final AudioPlayer _audioPlayer;
  ConcatenatingAudioSource? _playlist;
  AndroidEqualizer? _equalizer;
  final OfflineTrackService offlineService;

  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<SequenceState?> get sequenceStateStream =>
      _audioPlayer.sequenceStateStream;
  Stream<bool> get shuffleModeEnabledStream =>
      _audioPlayer.shuffleModeEnabledStream;
  Stream<LoopMode> get loopModeStream => _audioPlayer.loopModeStream;

  /// Getter for the equalizer (Android only). Null on other platforms.
  AndroidEqualizer? get equalizer => _equalizer;

  AudioPlayerService({required this.offlineService}) {
    if (!kIsWeb && Platform.isAndroid) {
      _equalizer = AndroidEqualizer();
      _audioPlayer = AudioPlayer(
        audioPipeline: AudioPipeline(
          androidAudioEffects: [_equalizer!],
        ),
      );
    } else {
      _audioPlayer = AudioPlayer();
    }
  }

  /// Build an AudioSource for a track – uses local file if downloaded.
  Future<AudioSource> _createAudioSource(Track track) async {
    final localPath = await offlineService.getLocalFilePath(track.id);
    final uri = localPath != null
        ? Uri.file(localPath)
        : Uri.parse(track.url);

    return AudioSource.uri(
      uri,
      tag: MediaItem(
        id: track.id,
        album: track.albumId,
        title: track.title,
        artist:
            track.artistIds.isNotEmpty ? track.artistIds.first : 'Unknown Artist',
        artUri: !kIsWeb &&
                track.coverUrl != null &&
                track.coverUrl!.startsWith('http')
            ? Uri.parse(track.coverUrl!)
            : null,
      ),
    );
  }

  Future<void> setPlaylist(List<Track> tracks, {int initialIndex = 0}) async {
    try {
      final audioSources =
          await Future.wait(tracks.map((t) => _createAudioSource(t)));

      _playlist = ConcatenatingAudioSource(children: audioSources);
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(
        _playlist!,
        initialIndex: initialIndex,
      );
      await _audioPlayer.play();

      // Enable equalizer after playback starts (Android only)
      if (_equalizer != null) {
        await _equalizer!.setEnabled(true);
      }
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
      if (existingIndex == targetIndex || existingIndex == targetIndex - 1) {
        return;
      }

      _playlist!.removeAt(existingIndex);
      int insertPos = targetIndex;
      if (existingIndex < targetIndex) {
        insertPos--;
      }
      _createAudioSource(track).then((src) => _playlist!.insert(insertPos, src));
    } else {
      _createAudioSource(track).then((src) => _playlist!.insert(targetIndex, src));
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
    _createAudioSource(track).then((src) => _playlist!.add(src));
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

  /// Apply equalizer band values (in dB). Android only.
  Future<void> applyEqualizerBands(List<double> bandValues) async {
    if (_equalizer == null) return;
    try {
      final params = await _equalizer!.parameters;
      final bands = params.bands;
      for (int i = 0; i < bands.length && i < bandValues.length; i++) {
        await bands[i].setGain(bandValues[i]);
      }
    } catch (e) {
      debugPrint('Equalizer error: $e');
    }
  }

  void dispose() {
    _equalizer?.setEnabled(false);
    _audioPlayer.dispose();
  }
}
