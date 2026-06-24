import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/main.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import 'package:music_app/features/explore/presentation/controllers/featured_tracks_notifier.dart';
import 'package:music_app/features/player/presentation/controllers/player_notifier.dart';

class FakeTrackRepository implements TrackRepository {
  final mockTrack = const Track(
    id: '1',
    title: 'Fake Track',
    artistIds: ['Artist'],
    albumId: 'Album',
    coverUrl: 'http://example.com/cover.jpg',
    url: 'http://example.com/audio.mp3',
    durationMs: 180000,
  );

  @override
  Future<List<Track>> getFeaturedTracks() async => [mockTrack];

  @override
  Future<List<Track>> getPopularTracks() async => [mockTrack];

  @override
  Future<List<Track>> getNewTracks() async => [mockTrack];

  @override
  Future<List<Track>> searchTracks(String query) async => [mockTrack];

  @override
  Future<List<Track>> getAllTracks() async => [mockTrack];
}

void main() {
  testWidgets('App smoke test - verifies home page title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          featuredTrackRepositoryProvider.overrideWithValue(FakeTrackRepository()),
          trackRepositoryProvider.overrideWithValue(FakeTrackRepository()),
        ],
        child: const MyApp(),
      ),
    );

    // Let it render
    await tester.pumpAndSettle();

    // Verify that the title 'Harmonix' is displayed.
    expect(find.text('Harmonix'), findsOneWidget);
  });
}
