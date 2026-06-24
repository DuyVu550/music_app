import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/player/domain/entities/player_state.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import 'package:music_app/features/player/presentation/controllers/player_notifier.dart';
import 'package:music_app/features/explore/presentation/pages/popular_songs_page.dart';

class FakeTrackRepository implements TrackRepository {
  final List<Track> tracks;
  FakeTrackRepository({required this.tracks});

  @override
  Future<List<Track>> getFeaturedTracks() async => [];

  @override
  Future<List<Track>> getPopularTracks() async => tracks;

  @override
  Future<List<Track>> getNewTracks() async => [];

  @override
  Future<List<Track>> searchTracks(String query) async => [];

  @override
  Future<List<Track>> getAllTracks() async => [];
}

class FakePlayerNotifier extends PlayerNotifier {
  final PlayerState _initialState;
  FakePlayerNotifier(this._initialState);

  @override
  Future<PlayerState> build() async {
    return _initialState;
  }

  Track? playedTrack;
  bool isPlayingToggled = false;
  bool isStopped = false;

  @override
  void playTrack(Track track) {
    playedTrack = track;
    state = AsyncData(state.value!.copyWith(currentTrack: track, isPlaying: true));
  }

  @override
  void togglePlay() {
    isPlayingToggled = true;
    state = AsyncData(state.value!.copyWith(isPlaying: !state.value!.isPlaying));
  }

  @override
  void stop() {
    isStopped = true;
    state = AsyncData(state.value!.copyWith(currentTrack: null, isPlaying: false));
  }
}

void main() {
  final mockTracks = [
    const Track(
      id: 'p1',
      title: 'Popular Song 1',
      artistIds: ['Artist Alpha'],
      albumId: 'Album X',
      coverUrl: 'http://example.com/cover1.jpg',
      url: 'http://example.com/audio1.mp3',
      durationMs: 220000,
    ),
    const Track(
      id: 'p2',
      title: 'Popular Song 2',
      artistIds: ['Artist Beta'],
      albumId: 'Album Y',
      coverUrl: '',
      url: 'http://example.com/audio2.mp3',
      durationMs: 250000,
    ),
  ];

  testWidgets('PopularSongsPage displays popular tracks and plays a track on tap', (WidgetTester tester) async {
    final fakeTrackRepo = FakeTrackRepository(tracks: mockTracks);
    final initialPlayerState = PlayerState(
      playlist: [],
      currentTrack: null,
      isPlaying: false,
    );
    final fakePlayerNotifier = FakePlayerNotifier(initialPlayerState);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackRepositoryProvider.overrideWithValue(fakeTrackRepo),
          playerNotifierProvider.overrideWith(() => fakePlayerNotifier),
        ],
        child: const MaterialApp(
          home: PopularSongsPage(),
        ),
      ),
    );

    // Verify loading indicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the provider load the data
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('Bài hát phổ biến'), findsOneWidget);

    // Verify tracks are rendered
    expect(find.text('Popular Song 1'), findsOneWidget);
    expect(find.text('Artist Alpha'), findsOneWidget);
    expect(find.text('Popular Song 2'), findsOneWidget);
    expect(find.text('Artist Beta'), findsOneWidget);

    // Bottom player shouldn't be active yet
    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsNothing);

    // Tap on the first track to play it
    await tester.tap(find.text('Popular Song 1'));
    await tester.pumpAndSettle();

    // Verify playTrack was called
    expect(fakePlayerNotifier.playedTrack, mockTracks[0]);

    // Verify bottom player is active with current track details
    expect(find.text('Popular Song 1'), findsWidgets);
    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);

    // Tap play/pause button
    await tester.tap(find.byIcon(Icons.pause_circle_filled_rounded));
    await tester.pumpAndSettle();

    expect(fakePlayerNotifier.isPlayingToggled, true);
    expect(find.byIcon(Icons.play_circle_filled_rounded), findsOneWidget);

    // Tap close button
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(fakePlayerNotifier.isStopped, true);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('PopularSongsPage displays empty list message when empty', (WidgetTester tester) async {
    final fakeTrackRepo = FakeTrackRepository(tracks: []);
    final initialPlayerState = PlayerState(
      playlist: [],
      currentTrack: null,
      isPlaying: false,
    );
    final fakePlayerNotifier = FakePlayerNotifier(initialPlayerState);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackRepositoryProvider.overrideWithValue(fakeTrackRepo),
          playerNotifierProvider.overrideWith(() => fakePlayerNotifier),
        ],
        child: const MaterialApp(
          home: PopularSongsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Không có bài hát phổ biến nào.'), findsOneWidget);
  });
}
