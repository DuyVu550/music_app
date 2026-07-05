import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/features/player/data/repositories/track_repository_impl.dart';
import 'package:music_app/features/player/domain/entities/track.dart';

void main() {
  group('TrackRepository Search Tests', () {
    late TrackRepositoryImpl repository;

    setUp(() {
      final mockTracks = [
        Track(
          id: "1",
          title: "Shape of You",
          url: "http://example.com/audio.mp3",
          albumId: "Album A",
          artistIds: ["Ed Sheeran"],
          durationMs: 233000,
          coverUrl: "http://example.com/image.jpg",
          listeners: 1200,
        )
      ];
      
      repository = TrackRepositoryImpl(initialTracks: mockTracks);
    });

    test('searchTracks returns a list of tracks when querying a song name', () async {
      // Act
      final tracks = await repository.searchTracks('Shape of You');

      // Assert
      expect(tracks, isNotNull);
      expect(tracks, isNotEmpty);
      
      final firstTrack = tracks.first;
      expect(firstTrack.id, isNotEmpty);
      expect(firstTrack.title.toLowerCase(), contains('shape of you'));
      expect(firstTrack.coverUrl, isNotNull);
      expect(firstTrack.coverUrl, startsWith('http'));
    });
  });
}
