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
  group('TrackRepository Search Tests', () {
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
          }
        ]
      };
      
      mockAdapter.responses['songs.json'] = jsonEncode(mockJson);
      mockAdapter.responses['music.json'] = jsonEncode([]);
      
      final dio = Dio()..httpClientAdapter = mockAdapter;
      repository = TrackRepositoryImpl(dio: dio);
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
