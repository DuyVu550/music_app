import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/presentation/controllers/player_notifier.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import 'package:music_app/features/player/data/datasources/audio_player_service.dart';

class FakeTrackRepository implements TrackRepository {
  final List<Track> tracks;
  FakeTrackRepository(this.tracks);

  @override
  Future<List<Track>> getFeaturedTracks() async => tracks;

  @override
  Future<List<Track>> getPopularTracks() async => tracks;

  @override
  Future<List<Track>> getNewTracks() async => tracks;

  @override
  Future<List<Track>> searchTracks(String query) async => tracks;

  @override
  Future<List<Track>> getAllTracks() async => tracks;
}

class FakeAudioPlayerService implements AudioPlayerService {
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _stateController = StreamController<ja.PlayerState>.broadcast();
  final _currentIndexController = StreamController<int?>.broadcast();

  bool _isPlaying = false;
  int? _currentIndex;

  void _emitState() {
    _stateController.add(ja.PlayerState(
      _isPlaying,
      ja.ProcessingState.ready,
    ));
  }

  @override
  Stream<Duration> get positionStream => _positionController.stream;
  @override
  Stream<Duration?> get durationStream => _durationController.stream;
  @override
  Stream<ja.PlayerState> get playerStateStream => _stateController.stream;
  @override
  Stream<int?> get currentIndexStream => _currentIndexController.stream;

  @override
  Future<void> setPlaylist(List<Track> tracks, {int initialIndex = 0}) async {
    _currentIndex = initialIndex;
    _currentIndexController.add(_currentIndex);
    _isPlaying = true;
    _emitState();
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
    }
  }

  @override
  void seekToNext() {
    if (_currentIndex != null) {
      _currentIndex = _currentIndex! + 1;
      _currentIndexController.add(_currentIndex);
    }
  }

  @override
  void seekToPrevious() {
    if (_currentIndex != null && _currentIndex! > 0) {
      _currentIndex = _currentIndex! - 1;
      _currentIndexController.add(_currentIndex);
    }
  }

  @override
  void stop() {
    _isPlaying = false;
    _emitState();
  }

  @override
  void dispose() {
    _positionController.close();
    _durationController.close();
    _stateController.close();
    _currentIndexController.close();
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
          trackRepositoryProvider.overrideWithValue(FakeTrackRepository(mockPlaylist)),
          audioPlayerServiceProvider.overrideWithValue(FakeAudioPlayerService()),
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
      expect(container.read(playerNotifierProvider).value?.currentTrack?.id, equals('1'));

      notifier.nextTrack();
      await Future.delayed(Duration.zero);
      expect(container.read(playerNotifierProvider).value?.currentTrack?.id, equals('2'));
      expect(container.read(playerNotifierProvider).value?.isPlaying, isTrue);
    });

    test('previousTrack returns to prior track', () async {
      await container.read(playerNotifierProvider.future);
      final notifier = container.read(playerNotifierProvider.notifier);

      notifier.playTrack(mockPlaylist[1]);
      expect(container.read(playerNotifierProvider).value?.currentTrack?.id, equals('2'));

      notifier.previousTrack();
      await Future.delayed(Duration.zero);
      expect(container.read(playerNotifierProvider).value?.currentTrack?.id, equals('1'));
      expect(container.read(playerNotifierProvider).value?.isPlaying, isTrue);
    });

    test('stop clears current track, resets position, and stops playing', () async {
      await container.read(playerNotifierProvider.future);
      final notifier = container.read(playerNotifierProvider.notifier);

      notifier.playTrack(mockPlaylist[0]);
      notifier.updatePosition(const Duration(seconds: 45));
      expect(container.read(playerNotifierProvider).value?.currentTrack, isNotNull);
      expect(container.read(playerNotifierProvider).value?.isPlaying, isTrue);
      expect(container.read(playerNotifierProvider).value?.position, equals(const Duration(seconds: 45)));

      notifier.stop();
      final stoppedState = container.read(playerNotifierProvider).value;
      expect(stoppedState?.currentTrack, isNull);
      expect(stoppedState?.isPlaying, isFalse);
      expect(stoppedState?.position, equals(Duration.zero));
    });
  });
}
