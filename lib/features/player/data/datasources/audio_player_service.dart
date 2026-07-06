// ignore_for_file: deprecated_member_use
import 'dart:async';
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
  late final AudioPlayer _primaryPlayer;
  late final AudioPlayer _secondaryPlayer;
  ConcatenatingAudioSource? _playlist;
  AndroidEqualizer? _equalizer;
  final OfflineTrackService offlineService;

  // Crossfade state
  Duration _crossfadeDuration = Duration.zero;
  bool _isCrossfading = false;
  Timer? _fadeTimer;

  Stream<Duration> get positionStream => _primaryPlayer.positionStream;
  Stream<Duration?> get durationStream => _primaryPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _primaryPlayer.playerStateStream;
  Stream<SequenceState?> get sequenceStateStream =>
      _primaryPlayer.sequenceStateStream;
  Stream<bool> get shuffleModeEnabledStream =>
      _primaryPlayer.shuffleModeEnabledStream;
  Stream<LoopMode> get loopModeStream => _primaryPlayer.loopModeStream;

  /// Getter for the equalizer (Android only). Null on other platforms.
  AndroidEqualizer? get equalizer => _equalizer;

  AudioPlayerService({required this.offlineService}) {
    if (!kIsWeb && Platform.isAndroid) {
      _equalizer = AndroidEqualizer();
      _primaryPlayer = AudioPlayer(
        audioPipeline: AudioPipeline(
          androidAudioEffects: [_equalizer!],
        ),
      );
    } else {
      _primaryPlayer = AudioPlayer();
    }
    // ponytail: secondary player has no equalizer pipeline; acceptable trade-off
    _secondaryPlayer = AudioPlayer();
  }

  void setCrossfadeDuration(Duration duration) {
    _crossfadeDuration = duration;
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
      await _primaryPlayer.stop();
      await _primaryPlayer.setAudioSource(
        _playlist!,
        initialIndex: initialIndex,
      );
      await _primaryPlayer.play();

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
    final currentIndex = _primaryPlayer.currentIndex ?? -1;
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
      final currentIndex = _primaryPlayer.currentIndex ?? -1;
      if (index == currentIndex) {
        seekToNext();
      }
      _playlist!.removeAt(index);
    }
  }

  void resume() {
    _primaryPlayer.play();
  }

  void pause() {
    _primaryPlayer.pause();
  }

  void seek(Duration position, {int? index}) {
    resetCrossfade(); // Cancel any ongoing crossfade on manual seek
    _primaryPlayer.seek(position, index: index);
  }

  void seekToNext() {
    _primaryPlayer.seekToNext();
  }

  void seekToPrevious() {
    _primaryPlayer.seekToPrevious();
  }

  void setShuffleModeEnabled(bool enabled) {
    _primaryPlayer.setShuffleModeEnabled(enabled);
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
    _primaryPlayer.setLoopMode(jaMode);
  }

  void stop() {
    resetCrossfade();
    _primaryPlayer.stop();
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

  /// Start crossfade: fade out primary, fade in secondary playing [nextTrack].
  Future<void> startCrossfade(Track nextTrack) async {
    if (_isCrossfading) return;
    if (_crossfadeDuration <= Duration.zero) return;

    _isCrossfading = true;

    try {
      final source = await _createAudioSource(nextTrack);
      await _secondaryPlayer.setAudioSource(source);
      await _secondaryPlayer.setVolume(0.0);
      await _secondaryPlayer.play();
    } catch (e) {
      debugPrint('Crossfade load error: $e');
      _isCrossfading = false;
      return;
    }

    final totalMs = _crossfadeDuration.inMilliseconds;
    const tickMs = 50;
    int elapsed = 0;

    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: tickMs), (timer) async {
      elapsed += tickMs;
      final t = (elapsed / totalMs).clamp(0.0, 1.0);

      try {
        await _primaryPlayer.setVolume(1.0 - t);
        await _secondaryPlayer.setVolume(t);
      } catch (_) {}

      if (t >= 1.0) {
        timer.cancel();
        _fadeTimer = null;
        try {
          await _primaryPlayer.stop();
          await _primaryPlayer.setVolume(1.0);
        } catch (_) {}
        _isCrossfading = false;
        // ponytail: secondary stops after crossfade; primary resumes next
        // track via just_audio sequenceStateStream + PlayerNotifier.playTrack
        Future.delayed(const Duration(milliseconds: 200), () {
          _secondaryPlayer.stop();
        });
      }
    });
  }

  /// Cancel any in-progress crossfade and restore primary volume.
  void resetCrossfade() {
    if (!_isCrossfading) return;
    _fadeTimer?.cancel();
    _fadeTimer = null;
    _isCrossfading = false;
    _primaryPlayer.setVolume(1.0);
    _secondaryPlayer.stop();
  }

  bool get isCrossfading => _isCrossfading;

  void dispose() {
    _fadeTimer?.cancel();
    _equalizer?.setEnabled(false);
    _primaryPlayer.dispose();
    _secondaryPlayer.dispose();
  }
}
