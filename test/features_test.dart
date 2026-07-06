import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/features/admin/domain/models/song_model.dart';
import 'package:music_app/features/player/domain/entities/track.dart';

void main() {
  group('SongModel & Album Integration Tests', () {
    test('SongModel should support albumId in fromJson and toJson', () {
      final json = {
        'id': 'test_song_1',
        'title': 'Test Song',
        'artist': 'Test Artist',
        'audioUrl': 'https://example.com/audio.mp3',
        'coverUrl': 'https://example.com/cover.png',
        'lyrics': 'Test Lyrics',
        'albumId': 'test_album_123',
      };

      final song = SongModel.fromJson(json);
      expect(song.albumId, equals('test_album_123'));
      expect(song.lyrics, equals('Test Lyrics'));

      final generatedJson = song.toJson();
      expect(generatedJson['albumId'], equals('test_album_123'));
    });

    test('SongModel copyWith should properly update albumId', () {
      final song = SongModel(
        id: '1',
        title: 'Song',
        artist: 'Artist',
        audioUrl: 'url',
        coverUrl: 'cover',
        createdAt: DateTime.now(),
        albumId: 'album_a',
      );

      final updated = song.copyWith(albumId: 'album_b');
      expect(updated.albumId, equals('album_b'));
      expect(updated.title, equals('Song'));
    });
  });

  group('Track entities structure tests', () {
    test('Track class from player domain should have listeners and albumId', () {
      const track = Track(
        id: 'track_1',
        title: 'Track Title',
        url: 'url',
        artistIds: ['Artist Name'],
        albumId: 'album_123',
        listeners: 42,
      );

      expect(track.albumId, equals('album_123'));
      expect(track.listeners, equals(42));
    });
  });
}
