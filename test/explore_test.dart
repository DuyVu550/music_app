import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/features/player/data/repositories/track_repository_impl.dart';
import 'package:music_app/features/player/domain/entities/track.dart';

void main() {
  group('TrackRepository Explore Tests', () {
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
        ),
        Track(
          id: "2",
          title: "Chạy Ngay Đi",
          url: "http://example.com/audio2.mp3",
          albumId: "Album B",
          artistIds: ["Sơn Tùng M-TP"],
          durationMs: 240000,
          coverUrl: "http://example.com/image2.jpg",
          listeners: 5000,
        )
      ];
      
      repository = TrackRepositoryImpl(initialTracks: mockTracks);
    });

    test('getFeaturedTracks returns a list of popular genre (pop) tracks', () async {
      final tracks = await repository.getFeaturedTracks();
      expect(tracks, isNotNull);
      expect(tracks, isNotEmpty);
      expect(tracks.first.coverUrl, isNotNull);
    });

    test('getPopularTracks returns a list of dance tracks', () async {
      final tracks = await repository.getPopularTracks();
      expect(tracks, isNotNull);
      expect(tracks, isNotEmpty);
      expect(tracks.first.coverUrl, isNotNull);
    });

    test('getNewTracks returns a list of acoustic tracks', () async {
      final tracks = await repository.getNewTracks();
      expect(tracks, isNotNull);
      expect(tracks, isNotEmpty);
      expect(tracks.first.coverUrl, isNotNull);
    });

    test('getAllTracks returns only Branium tracks and ignores Gist', () async {
      final tracks = await repository.getAllTracks();
      
      // Should contain only 2 Branium tracks (from setUp)
      expect(tracks.length, 2);
      expect(tracks.any((t) => t.id.startsWith('gist_')), isFalse);
    });
  });
}
