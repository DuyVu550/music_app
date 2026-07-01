import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_app/features/explore/presentation/pages/artist_list_page.dart';
import 'package:music_app/features/player/domain/repositories/track_repository.dart';
import 'package:music_app/features/explore/domain/entities/artist.dart';
import 'package:music_app/features/player/domain/entities/track.dart';
import 'package:music_app/features/explore/domain/entities/category.dart';
import 'package:music_app/features/auth/presentation/controllers/auth_notifier.dart';
import 'fakes.dart';

class FakeArtistTrackRepository implements TrackRepository {
  final List<Artist> artists;

  FakeArtistTrackRepository({required this.artists});

  @override
  Future<List<Artist>> getArtists() async => artists;

  @override
  Stream<List<Track>> getPopularTracksStream() => Stream.value([]);
  @override
  Future<List<Track>> getFeaturedTracks() async => [];
  @override
  Future<List<Track>> getPopularTracks() async => [];
  @override
  Future<List<Track>> getNewTracks() async => [];
  @override
  Future<List<Track>> searchTracks(String query) async => [];
  @override
  Future<List<Track>> getAllTracks() async => [];
  @override
  Stream<List<Track>> getAllTracksStream() => Stream.value([]);
  @override
  Future<List<Category>> getCategories() async => [];
  @override
  Future<List<Track>> getTracksByCategory(String categoryId) async => [];
  @override
  Future<List<Track>> getTracksByArtist(String artistId) async => [];
}

void main() {
  final testArtists = [
    const Artist(id: 'a1', name: 'Ed Sheeran', imageUrl: 'http://example.com/ed.jpg'),
    const Artist(id: 'a2', name: 'Sơn Tùng M-TP', imageUrl: 'http://example.com/sontung.jpg'),
    const Artist(id: 'a3', name: 'Taylor Swift', imageUrl: 'http://example.com/taylor.jpg'),
  ];

  testWidgets('ArtistListPage displays artists and allows searching', (WidgetTester tester) async {
    final fakeRepo = FakeArtistTrackRepository(artists: testArtists);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackRepositoryProvider.overrideWithValue(fakeRepo),
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
        ],
        child: const MaterialApp(
          home: ArtistListPage(),
        ),
      ),
    );

    // Initial loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Load data
    await tester.pumpAndSettle();

    // Verify artists are displayed
    expect(find.text('Ed Sheeran'), findsOneWidget);
    expect(find.text('Sơn Tùng M-TP'), findsOneWidget);
    expect(find.text('Taylor Swift'), findsOneWidget);

    // Search for "Ed"
    await tester.enterText(find.byType(TextField), 'Ed');
    await tester.pumpAndSettle();

    // Verify only Ed Sheeran matches
    expect(find.text('Ed Sheeran'), findsOneWidget);
    expect(find.text('Sơn Tùng M-TP'), findsNothing);
    expect(find.text('Taylor Swift'), findsNothing);

    // Clear search using the clear button
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();

    // Verify all artists are displayed again
    expect(find.text('Ed Sheeran'), findsOneWidget);
    expect(find.text('Sơn Tùng M-TP'), findsOneWidget);
    expect(find.text('Taylor Swift'), findsOneWidget);

    // Search for non-existent artist
    await tester.enterText(find.byType(TextField), 'Nonexistent Artist');
    await tester.pumpAndSettle();

    // Verify no artists match and empty message is shown
    expect(find.text('Ed Sheeran'), findsNothing);
    expect(find.text('Không tìm thấy nghệ sĩ nào phù hợp.'), findsOneWidget);
  });
}
