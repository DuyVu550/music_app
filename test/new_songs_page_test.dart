import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/player/domain/entities/player_state.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import 'package:music_app/features/player/presentation/controllers/player_notifier.dart';
import 'package:music_app/features/explore/presentation/pages/new_songs_page.dart';
import 'package:music_app/features/explore/domain/entities/category.dart';
import 'package:music_app/features/explore/domain/entities/artist.dart';
import 'package:music_app/features/player/presentation/widgets/global_bottom_player.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:music_app/features/favorites/data/repositories/favorite_repository.dart';
import 'fakes.dart';

class FakeTrackRepository implements TrackRepository {
  @override
  Stream<List<Track>> getPopularTracksStream() => Stream.value([]);
  final List<Track> tracks;
  FakeTrackRepository({required this.tracks});

  @override
  Future<List<Track>> getFeaturedTracks() async => [];

  @override
  Future<List<Track>> getPopularTracks() async => [];

  @override
  Future<List<Track>> getNewTracks() async => tracks;

  @override
  Future<List<Track>> searchTracks(String query) async => [];

  @override
  Future<List<Track>> getAllTracks() async => [];

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
      id: 'n1',
      title: 'New Song 1',
      artistIds: ['Artist A'],
      albumId: 'Album 1',
      coverUrl: 'http://example.com/cover1.jpg',
      url: 'http://example.com/audio1.mp3',
      durationMs: 200000,
    ),
    const Track(
      id: 'n2',
      title: 'New Song 2',
      artistIds: ['Artist B'],
      albumId: 'Album 2',
      coverUrl: '',
      url: 'http://example.com/audio2.mp3',
      durationMs: 210000,
    ),
  ];

  testWidgets('NewSongsPage displays new tracks and plays a track on tap', (WidgetTester tester) async {
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
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
          favoriteRepositoryProvider.overrideWithValue(FakeFavoriteRepository()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                NewSongsPage(),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GlobalBottomPlayerWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Initial state: loading indicator should be visible
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the provider load the data
    await tester.pumpAndSettle();

    // Verify title is shown
    expect(find.text('Bài hát mới nhất'), findsOneWidget);

    // Verify tracks are listed
    expect(find.text('New Song 1'), findsOneWidget);
    expect(find.text('Artist A'), findsOneWidget);
    expect(find.text('New Song 2'), findsOneWidget);
    expect(find.text('Artist B'), findsOneWidget);

    // Bottom player should not be shown since currentTrack is null
    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsNothing);

    // Tap on the first song to play it
    await tester.tap(find.text('New Song 1'));
    await tester.pumpAndSettle();

    // Verify playTrack was called with the correct track
    expect(fakePlayerNotifier.playedTrack, mockTracks[0]);

    // Verify the bottom player now appears displaying the playing song
    expect(find.text('New Song 1'), findsWidgets); // one in the list, one in bottom player
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

  testWidgets('NewSongsPage displays empty list message when empty', (WidgetTester tester) async {
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
          home: NewSongsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Không có bài hát mới nào.'), findsOneWidget);
  });
}
