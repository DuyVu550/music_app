import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/features/player/data/repositories/track_repository_impl.dart';

class MockAdapter implements HttpClientAdapter {
  final Map<String, String> responses = {};

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    for (final entry in responses.entries) {
      if (options.path.contains(entry.key)) {
        return ResponseBody.fromString(
          entry.value,
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
    }
    throw UnimplementedError("No mock response for path: ${options.path}");
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('TrackRepository Explore Tests', () {
    late TrackRepositoryImpl repository;
    late MockAdapter mockAdapter;

    setUp(() {
      mockAdapter = MockAdapter();
      final mockJson = {
        "songs": [
          {
            "id": "1",
            "title": "Shape of You",
            "source": "http://example.com/audio.mp3",
            "album": "Album A",
            "artist": "Ed Sheeran",
            "duration": 233,
            "image": "http://example.com/image.jpg",
            "counter": 1200
          },
          {
            "id": "2",
            "title": "Chạy Ngay Đi",
            "source": "http://example.com/audio2.mp3",
            "album": "Album B",
            "artist": "Sơn Tùng M-TP",
            "duration": 240,
            "image": "http://example.com/image2.jpg",
            "counter": 5000
          }
        ]
      };
      
      mockAdapter.responses['songs.json'] = jsonEncode(mockJson);
      mockAdapter.responses['music.json'] = jsonEncode([]);
      
      final dio = Dio()..httpClientAdapter = mockAdapter;
      repository = TrackRepositoryImpl(dio: dio);
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
      final mockGistJson = [
        {
          "name": "Radiohead",
          "albums": [
            {
              "title": "The King of Limbs",
              "songs": [
                {
                  "title": "Bloom",
                  "length": "5:15"
                }
              ],
              "description": "Album Description"
            }
          ]
        }
      ];

      mockAdapter.responses['music.json'] = jsonEncode(mockGistJson);

      final tracks = await repository.getAllTracks();
      
      // Should contain only 2 Branium tracks (from setUp)
      expect(tracks.length, 2);
      expect(tracks.any((t) => t.id.startsWith('gist_')), isFalse);
    });
  });
}
