import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/player/domain/entities/player_state.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/presentation/controllers/player_notifier.dart';
import 'package:music_app/features/explore/presentation/pages/all_songs_page.dart';
import 'package:music_app/features/explore/presentation/controllers/all_tracks_notifier.dart';
import 'package:music_app/features/player/presentation/widgets/global_bottom_player.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:music_app/features/favorites/data/repositories/favorite_repository.dart';
import 'fakes.dart';

class FakePlayerNotifier extends PlayerNotifier {
  final PlayerState _initialState;
  FakePlayerNotifier(this._initialState);

  @override
  Future<PlayerState> build() async {
    return _initialState;
  }

  @override
  void playTrack(Track track) {
    state = AsyncData(
      state.value!.copyWith(currentTrack: track, isPlaying: true),
    );
  }

  @override
  void togglePlay() {
    state = AsyncData(
      state.value!.copyWith(isPlaying: !state.value!.isPlaying),
    );
  }

  @override
  void stop() {
    state = AsyncData(
      state.value!.copyWith(currentTrack: null, isPlaying: false),
    );
  }
}

class FakeAllTracksNotifier extends AllTracksNotifier {
  final List<Track> _tracks;
  FakeAllTracksNotifier(this._tracks);

  @override
  Future<List<Track>> build() async {
    return _tracks;
  }
}

void main() {
  testWidgets(
    'Bottom Player displays when currentTrack is active and controls trigger action',
    (WidgetTester tester) async {
      final mockTrack = const Track(
        id: '1',
        title: 'Test Song Title',
        artistIds: ['Test Artist'],
        albumId: 'Album 1',
        coverUrl: 'http://example.com/cover.jpg',
        url: 'http://example.com/preview.mp3',
        durationMs: 180000,
      );

      final playerState = PlayerState(
        playlist: [mockTrack],
        currentTrack: mockTrack,
        isPlaying: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerNotifierProvider.overrideWith(
              () => FakePlayerNotifier(playerState),
            ),
            allTracksProvider.overrideWith(
              () => FakeAllTracksNotifier([mockTrack]),
            ),
            authNotifierProvider.overrideWith(
              () => FakeAuthNotifier(),
            ),
            favoriteRepositoryProvider.overrideWithValue(
              FakeFavoriteRepository(),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Stack(
                children: [
                  const AllSongsPage(),
                  const Positioned(
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

      // Wait for the UI to settle
      await tester.pumpAndSettle();

      // Verify track details are displayed in bottom player
      expect(find.text('Test Song Title'), findsWidgets);
      expect(find.text('Test Artist'), findsWidgets);

      // Verify control icons exist
      expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap pause button and assert state
      await tester.tap(find.byIcon(Icons.pause_circle_filled_rounded));
      await tester.pump();
    },
  );
}
