import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/presentation/controllers/player_notifier.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import 'package:music_app/features/player/domain/entities/player_loop_mode.dart';
import 'package:music_app/features/player/data/datasources/audio_player_service.dart';
import 'package:music_app/features/explore/domain/entities/category.dart';
import 'package:music_app/features/explore/domain/entities/artist.dart';
import 'package:music_app/features/player/data/datasources/offline_track_service.dart';

class FakeTrackRepository implements TrackRepository {
  final List<Track> tracks;
  FakeTrackRepository(this.tracks);

  @override
  Future<List<Track>> getFeaturedTracks() async => tracks;

  @override
  Future<List<Track>> getPopularTracks() async => tracks;

  @override
  Stream<List<Track>> getPopularTracksStream() => Stream.value(tracks);

  @override
  Future<List<Track>> getNewTracks() async => tracks;

  @override
  Future<List<Track>> searchTracks(String query) async => tracks;

  @override
  Future<List<Track>> getAllTracks() async => tracks;

  @override
  Stream<List<Track>> getAllTracksStream() => Stream.value(tracks);

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<List<Artist>> getArtists() async => [];

  @override
  Future<List<Track>> getTracksByCategory(String categoryId) async => [];

  @override
  Future<List<Track>> getTracksByArtist(String artistId) async => [];

  @override
  Future<void> incrementListeners(String trackId) async {}

  @override
  Future<void> recordListeningHistory(String userId, Track track) async {}

  @override
  Future<List<Map<String, dynamic>>> getListeningHistory(String userId) async => [];
}


class FakeSequenceState implements ja.SequenceState {
  @override
  final ja.IndexedAudioSource? currentSource;
  FakeSequenceState(this.currentSource);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeIndexedAudioSource implements ja.IndexedAudioSource {
  @override
  final dynamic tag;
  FakeIndexedAudioSource(this.tag);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTag {
  final String id;
  FakeTag(this.id);
}

class FakeOfflineTrackService implements OfflineTrackService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAudioPlayerService implements AudioPlayerService {
  @override
  final FakeOfflineTrackService offlineService = FakeOfflineTrackService();

  @override
  ja.AndroidEqualizer? get equalizer => null;

  @override
  Future<void> applyEqualizerBands(List<double> bandValues) async {}

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _stateController = StreamController<ja.PlayerState>.broadcast();
  final _currentIndexController = StreamController<int?>.broadcast();
  final _sequenceStateController =
      StreamController<ja.SequenceState?>.broadcast();
  final _shuffleController = StreamController<bool>.broadcast();
  final _loopModeController = StreamController<ja.LoopMode>.broadcast();

  bool _isPlaying = false;
  int? _currentIndex;
  List<Track> _tracks = [];

  void _emitState() {
    _stateController.add(ja.PlayerState(_isPlaying, ja.ProcessingState.ready));
  }

  void _emitSequenceState() {
    if (_currentIndex != null &&
        _currentIndex! >= 0 &&
        _currentIndex! < _tracks.length) {
      final track = _tracks[_currentIndex!];
      final fakeTag = FakeTag(track.id);
      final fakeSource = FakeIndexedAudioSource(fakeTag);
      final fakeSeqState = FakeSequenceState(fakeSource);
      _sequenceStateController.add(fakeSeqState);
    } else {
      _sequenceStateController.add(null);
    }
  }

  @override
  Stream<Duration> get positionStream => _positionController.stream;
  @override
  Stream<Duration?> get durationStream => _durationController.stream;
  @override
  Stream<ja.PlayerState> get playerStateStream => _stateController.stream;
  @override
  Stream<ja.SequenceState?> get sequenceStateStream =>
      _sequenceStateController.stream;
  @override
  Stream<bool> get shuffleModeEnabledStream => _shuffleController.stream;
  @override
  Stream<ja.LoopMode> get loopModeStream => _loopModeController.stream;

  Stream<int?> get currentIndexStream => _currentIndexController.stream;

  @override
  Future<void> setPlaylist(List<Track> tracks, {int initialIndex = 0}) async {
    _tracks = tracks;
    _currentIndex = initialIndex;
    _currentIndexController.add(_currentIndex);
    _isPlaying = true;
    _emitState();
    _emitSequenceState();
  }

  @override
  void resume() {
    _isPlaying = true;
    _emitState();
  }

  @override
  void pause() {
    _isPlaying = false;
    _emitState();
  }

  @override
  void seek(Duration position, {int? index}) {
    if (index != null) {
      _currentIndex = index;
      _currentIndexController.add(_currentIndex);
      _emitSequenceState();
    }
  }

  @override
  void seekToNext() {
    if (_currentIndex != null && _currentIndex! < _tracks.length - 1) {
      _currentIndex = _currentIndex! + 1;
      _currentIndexController.add(_currentIndex);
      _emitSequenceState();
    }
  }

  @override
  void seekToPrevious() {
    if (_currentIndex != null && _currentIndex! > 0) {
      _currentIndex = _currentIndex! - 1;
      _currentIndexController.add(_currentIndex);
      _emitSequenceState();
    }
  }

  @override
  int getTrackIndexInPlaylist(String trackId) {
    return _tracks.indexWhere((t) => t.id == trackId);
  }

  @override
  void playNext(Track track) {
    final existingIndex = getTrackIndexInPlaylist(track.id);
    if (existingIndex >= 0) {
      _tracks.removeAt(existingIndex);
    }
    final targetIndex = (_currentIndex ?? -1) + 1;
    if (targetIndex >= 0 && targetIndex <= _tracks.length) {
      _tracks.insert(targetIndex, track);
    } else {
      _tracks.add(track);
    }
    _emitSequenceState();
  }

  @override
  void addToQueue(Track track) {
    final existingIndex = getTrackIndexInPlaylist(track.id);
    if (existingIndex >= 0) {
      _tracks.removeAt(existingIndex);
    }
    _tracks.add(track);
    _emitSequenceState();
  }

  @override
  void removeFromQueue(String trackId) {
    final existingIndex = getTrackIndexInPlaylist(trackId);
    if (existingIndex >= 0) {
      if (existingIndex == _currentIndex) {
        seekToNext();
      }
      _tracks.removeAt(existingIndex);
      _emitSequenceState();
    }
  }

  @override
  void stop() {
    _isPlaying = false;
    _emitState();
    _tracks = [];
    _currentIndex = null;
    _sequenceStateController.add(null);
  }

  @override
  Future<void> startCrossfade(Track nextTrack) async {}

  @override
  void resetCrossfade() {}

  @override
  void setCrossfadeDuration(Duration duration) {}

  @override
  bool get isCrossfading => false;

  @override
  void setShuffleModeEnabled(bool enabled) {
    _shuffleController.add(enabled);
  }

  @override
  void setLoopMode(PlayerLoopMode mode) {
    ja.LoopMode jaMode;
    switch (mode) {
      case PlayerLoopMode.off:
        jaMode = ja.LoopMode.off;
        break;
      case PlayerLoopMode.all:
        jaMode = ja.LoopMode.all;
        break;
      case PlayerLoopMode.one:
        jaMode = ja.LoopMode.one;
        break;
    }
    _loopModeController.add(jaMode);
  }

  @override
  void dispose() {
    _positionController.close();
    _durationController.close();
    _stateController.close();
    _currentIndexController.close();
    _sequenceStateController.close();
    _shuffleController.close();
    _loopModeController.close();
  }
}

void main() {
  group('PlayerNotifier State & Controls Test', () {
    late List<Track> mockPlaylist;
    late ProviderContainer container;

    setUp(() {
      mockPlaylist = [
        const Track(
          id: '1',
          title: 'Song One',
          artistIds: ['Artist A'],
          albumId: 'Album 1',
          coverUrl: 'http://example.com/1.jpg',
          url: 'http://example.com/1.mp3',
          durationMs: 180000,
        ),
        const Track(
          id: '2',
          title: 'Song Two',
          artistIds: ['Artist B'],
          albumId: 'Album 2',
          coverUrl: 'http://example.com/2.jpg',
          url: 'http://example.com/2.mp3',
          durationMs: 200000,
        ),
      ];

      container = ProviderContainer(
        overrides: [
          trackRepositoryProvider.overrideWithValue(
            FakeTrackRepository(mockPlaylist),
          ),
          audioPlayerServiceProvider.overrideWithValue(
            FakeAudioPlayerService(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state loads popular tracks as playlist', () async {
      final state = await container.read(playerNotifierProvider.future);
      expect(state.playlist, equals(mockPlaylist));
      expect(state.currentTrack, equals(mockPlaylist.first));
      expect(state.isPlaying, isFalse);
    });

    test('playTrack updates currentTrack and plays it', () async {
      await container.read(playerNotifierProvider.future);
      final notifier = container.read(playerNotifierProvider.notifier);

      notifier.playTrack(mockPlaylist[1]);

      final updatedState = container.read(playerNotifierProvider).value;
      expect(updatedState?.currentTrack, equals(mockPlaylist[1]));
      expect(updatedState?.isPlaying, isTrue);
    });

    test('togglePlay changes playing status', () async {
      await container.read(playerNotifierProvider.future);
      final notifier = container.read(playerNotifierProvider.notifier);

      // Default is not playing
      notifier.togglePlay();
      await Future.delayed(Duration.zero);
      expect(container.read(playerNotifierProvider).value?.isPlaying, isTrue);

      notifier.togglePlay();
      await Future.delayed(Duration.zero);
      expect(container.read(playerNotifierProvider).value?.isPlaying, isFalse);
    });

    test('nextTrack advances playlist and plays', () async {
      await container.read(playerNotifierProvider.future);
      final notifier = container.read(playerNotifierProvider.notifier);

      notifier.playTrack(mockPlaylist[0]);
      expect(
        container.read(playerNotifierProvider).value?.currentTrack?.id,
        equals('1'),
      );

      notifier.nextTrack();
      await Future.delayed(Duration.zero);
      expect(
        container.read(playerNotifierProvider).value?.currentTrack?.id,
        equals('2'),
      );
      expect(container.read(playerNotifierProvider).value?.isPlaying, isTrue);
    });

    test('previousTrack returns to prior track', () async {
      await container.read(playerNotifierProvider.future);
      final notifier = container.read(playerNotifierProvider.notifier);

      notifier.playTrack(mockPlaylist[1]);
      expect(
        container.read(playerNotifierProvider).value?.currentTrack?.id,
        equals('2'),
      );

      notifier.previousTrack();
      await Future.delayed(Duration.zero);
      expect(
        container.read(playerNotifierProvider).value?.currentTrack?.id,
        equals('1'),
      );
      expect(container.read(playerNotifierProvider).value?.isPlaying, isTrue);
    });

    test(
      'stop clears current track, resets position, and stops playing',
      () async {
        await container.read(playerNotifierProvider.future);
        final notifier = container.read(playerNotifierProvider.notifier);

        notifier.playTrack(mockPlaylist[0]);
        notifier.updatePosition(const Duration(seconds: 45));
        expect(
          container.read(playerNotifierProvider).value?.currentTrack,
          isNotNull,
        );
        expect(container.read(playerNotifierProvider).value?.isPlaying, isTrue);
        expect(
          container.read(playerNotifierProvider).value?.position,
          equals(const Duration(seconds: 45)),
        );

        notifier.stop();
        final stoppedState = container.read(playerNotifierProvider).value;
        expect(stoppedState?.currentTrack, isNull);
        expect(stoppedState?.isPlaying, isFalse);
        expect(stoppedState?.position, equals(Duration.zero));
      },
    );

    test('crossfadeDurationSeconds defaults to 0', () async {
      final state = await container.read(playerNotifierProvider.future);
      expect(state.crossfadeDurationSeconds, 0);
    });

    test('setCrossfadeDuration updates state', () async {
      await container.read(playerNotifierProvider.future);
      final notifier = container.read(playerNotifierProvider.notifier);
      notifier.setCrossfadeDuration(5);
      final state = container.read(playerNotifierProvider).value!;
      expect(state.crossfadeDurationSeconds, 5);
    });
  });
}
