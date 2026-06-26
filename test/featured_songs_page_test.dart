import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/player/domain/entities/player_state.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import 'package:music_app/features/player/presentation/controllers/player_notifier.dart';
import 'package:music_app/features/explore/presentation/pages/featured_songs_page.dart';
import 'package:music_app/features/explore/domain/entities/category.dart';
import 'package:music_app/features/explore/domain/entities/artist.dart';

class FakeTrackRepository implements TrackRepository {
  final List<Track> tracks;
  FakeTrackRepository({required this.tracks});

  @override
  Future<List<Track>> getFeaturedTracks() async => tracks;

  @override
  Future<List<Track>> getPopularTracks() async => [];

  @override
  Future<List<Track>> getNewTracks() async => [];

  @override
  Future<List<Track>> searchTracks(String query) async => [];

  @override
  Future<List<Track>> getAllTracks() async => [];

  @override
  Future<List<Category>> getCategories() async => [];

  @override
  Future<List<Artist>> getArtists() async => [];

  @override
  Future<List<Track>> getTracksByCategory(String categoryId) async => [];

  @override
  Future<List<Track>> getTracksByArtist(String artistId) async => [];
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
      id: 'f1',
      title: 'Featured Song 1',
      artistIds: ['Artist One'],
      albumId: 'Album A',
      coverUrl: 'http://example.com/cover1.jpg',
      url: 'http://example.com/audio1.mp3',
      durationMs: 200000,
    ),
    const Track(
      id: 'f2',
      title: 'Featured Song 2',
      artistIds: ['Artist Two'],
      albumId: 'Album B',
      coverUrl: '',
      url: 'http://example.com/audio2.mp3',
      durationMs: 240000,
    ),
  ];

  testWidgets('FeaturedSongsPage displays tracks and plays a track on tap', (WidgetTester tester) async {
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
          home: FeaturedSongsPage(),
        ),
      ),
    );

    // Initial state: loading indicator should be visible
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the provider load the data
    await tester.pumpAndSettle();

    // Verify title is shown
    expect(find.text('Bài hát nổi bật'), findsOneWidget);

    // Verify tracks are listed
    expect(find.text('Featured Song 1'), findsOneWidget);
    expect(find.text('Artist One'), findsOneWidget);
    expect(find.text('Featured Song 2'), findsOneWidget);
    expect(find.text('Artist Two'), findsOneWidget);

    // Bottom player should not be shown since currentTrack is null
    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsNothing);
    expect(find.byIcon(Icons.play_circle_filled_rounded), findsNothing);

    // Tap on the first song to play it
    await tester.tap(find.text('Featured Song 1'));
    await tester.pumpAndSettle();

    // Verify playTrack was called with the correct track
    expect(fakePlayerNotifier.playedTrack, mockTracks[0]);

    // Verify the bottom player now appears displaying the playing song
    expect(find.text('Featured Song 1'), findsWidgets); // one in the list, one in bottom player
    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);

    // Tap pause/play button on the bottom player
    await tester.tap(find.byIcon(Icons.pause_circle_filled_rounded));
    await tester.pumpAndSettle();

    // Verify togglePlay was called
    expect(fakePlayerNotifier.isPlayingToggled, true);
    expect(find.byIcon(Icons.play_circle_filled_rounded), findsOneWidget);

    // Tap close button on the bottom player
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Verify stop was called
    expect(fakePlayerNotifier.isStopped, true);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });

  testWidgets('FeaturedSongsPage displays empty list message when empty', (WidgetTester tester) async {
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
          home: FeaturedSongsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Không có bài hát nổi bật nào.'), findsOneWidget);
  });
}
