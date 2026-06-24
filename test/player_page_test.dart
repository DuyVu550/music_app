import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/player/domain/entities/player_state.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/presentation/controllers/player_notifier.dart';
import 'package:music_app/features/player/presentation/pages/player_page.dart';

class FakePlayerNotifier extends PlayerNotifier {
  final PlayerState _initialState;
  FakePlayerNotifier(this._initialState);

  bool playTrackCalled = false;
  Track? playedTrack;
  bool togglePlayCalled = false;
  bool nextTrackCalled = false;
  bool previousTrackCalled = false;
  bool seekCalled = false;
  Duration? seekPosition;

  @override
  Future<PlayerState> build() async {
    return _initialState;
  }

  @override
  void playTrack(Track track) {
    playTrackCalled = true;
    playedTrack = track;
    state = AsyncData(
      state.value!.copyWith(currentTrack: track, isPlaying: true),
    );
  }

  @override
  void togglePlay() {
    togglePlayCalled = true;
    state = AsyncData(
      state.value!.copyWith(isPlaying: !state.value!.isPlaying),
    );
  }

  @override
  void nextTrack() {
    nextTrackCalled = true;
  }

  @override
  void previousTrack() {
    previousTrackCalled = true;
  }

  @override
  void seek(Duration position) {
    seekCalled = true;
    seekPosition = position;
    state = AsyncData(
      state.value!.copyWith(position: position),
    );
  }
}

void main() {
  group('PlayerPage Widget Tests', () {
    late Track track1;
    late Track track2;
    late List<Track> mockPlaylist;

    setUp(() {
      track1 = const Track(
        id: '1',
        title: 'Song One',
        artistIds: ['Artist A'],
        albumId: 'Album 1',
        coverUrl: 'http://example.com/1.jpg',
        url: 'http://example.com/1.mp3',
        durationMs: 180000, // 3:00
      );
      track2 = const Track(
        id: '2',
        title: 'Song Two',
        artistIds: ['Artist B'],
        albumId: 'Album 2',
        coverUrl: 'http://example.com/2.jpg',
        url: 'http://example.com/2.mp3',
        durationMs: 240000, // 4:00
      );
      mockPlaylist = [track1, track2];
    });

    void setupViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('displays placeholder message when no track is playing', (WidgetTester tester) async {
      setupViewport(tester);
      final playerState = PlayerState(
        playlist: [],
        currentTrack: null,
        isPlaying: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerNotifierProvider.overrideWith(
              () => FakePlayerNotifier(playerState),
            ),
          ],
          child: const MaterialApp(
            home: PlayerPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Không có bài hát nào đang phát'), findsOneWidget);
    });

    testWidgets('displays track details, slider, and controls when playing', (WidgetTester tester) async {
      setupViewport(tester);
      final playerState = PlayerState(
        playlist: mockPlaylist,
        currentTrack: track1,
        isPlaying: true,
        position: const Duration(seconds: 45),
        duration: const Duration(minutes: 3),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerNotifierProvider.overrideWith(
              () => FakePlayerNotifier(playerState),
            ),
          ],
          child: const MaterialApp(
            home: PlayerPage(),
          ),
        ),
      );

      await tester.pump();

      // Check title and album
      expect(find.text('Song One'), findsNWidgets(2));
      expect(find.text('Mã Album: Album 1'), findsOneWidget);

      // Check duration formatted strings
      expect(find.text('00:45'), findsOneWidget); // current position
      expect(find.text('03:00'), findsOneWidget); // total duration

      // Verify Slider exists and has correct value & max
      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);
      final Slider slider = tester.widget(sliderFinder);
      expect(slider.value, 45.0);
      expect(slider.max, 180.0);

      // Verify controls
      expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);

      // Verify playlist is rendered
      expect(find.text('Danh Sách Đang Phát'), findsOneWidget);
      expect(find.text('Song Two'), findsOneWidget);

      // Song One is the current track, should show volume icon
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('clamps position correctly when position exceeds duration', (WidgetTester tester) async {
      setupViewport(tester);
      final playerState = PlayerState(
        playlist: mockPlaylist,
        currentTrack: track1,
        isPlaying: true,
        position: const Duration(minutes: 4), // 240 seconds, exceeding track1 duration (180 seconds)
        duration: const Duration(minutes: 3), // 180 seconds
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerNotifierProvider.overrideWith(
              () => FakePlayerNotifier(playerState),
            ),
          ],
          child: const MaterialApp(
            home: PlayerPage(),
          ),
        ),
      );

      await tester.pump();

      // Ensure Slider does not crash and is clamped to max duration (180)
      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);
      final Slider slider = tester.widget(sliderFinder);
      expect(slider.value, 180.0); // clamped to safeMax
      expect(slider.max, 180.0);
    });

    testWidgets('interacts with control buttons', (WidgetTester tester) async {
      setupViewport(tester);
      final playerState = PlayerState(
        playlist: mockPlaylist,
        currentTrack: track1,
        isPlaying: false,
        position: Duration.zero,
        duration: const Duration(minutes: 3),
      );

      final fakeNotifier = FakePlayerNotifier(playerState);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerNotifierProvider.overrideWith(() => fakeNotifier),
          ],
          child: const MaterialApp(
            home: PlayerPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Play
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      expect(fakeNotifier.togglePlayCalled, isTrue);

      // Tap Next
      await tester.tap(find.byIcon(Icons.skip_next_rounded));
      await tester.pump();
      expect(fakeNotifier.nextTrackCalled, isTrue);

      // Tap Previous
      await tester.tap(find.byIcon(Icons.skip_previous_rounded));
      await tester.pump();
      expect(fakeNotifier.previousTrackCalled, isTrue);
    });

    testWidgets('interacts with playlist items to play track', (WidgetTester tester) async {
      setupViewport(tester);
      final playerState = PlayerState(
        playlist: mockPlaylist,
        currentTrack: track1,
        isPlaying: true,
        position: Duration.zero,
        duration: const Duration(minutes: 3),
      );

      final fakeNotifier = FakePlayerNotifier(playerState);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerNotifierProvider.overrideWith(() => fakeNotifier),
          ],
          child: const MaterialApp(
            home: PlayerPage(),
          ),
        ),
      );

      await tester.pump();

      // Tap on Song Two in the playlist
      final songTwoFinder = find.text('Song Two');
      expect(songTwoFinder, findsOneWidget);
      await tester.tap(songTwoFinder);
      await tester.pump();

      expect(fakeNotifier.playTrackCalled, isTrue);
      expect(fakeNotifier.playedTrack, equals(track2));
    });
  });
}
