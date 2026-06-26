import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/features/explore/domain/entities/category.dart';
import 'package:music_app/features/explore/domain/entities/artist.dart';

void main() {
  group('Admin Models Serialization Tests', () {
    test('Category serialization and deserialization', () {
      final json = {
        'id': 'cat_123',
        'name': 'Nhạc Trẻ',
        'imageUrl': 'https://example.com/cat.png',
      };

      final category = Category.fromJson(json);
      expect(category.id, 'cat_123');
      expect(category.name, 'Nhạc Trẻ');
      expect(category.imageUrl, 'https://example.com/cat.png');

      final serialized = category.toJson();
      expect(serialized['id'], 'cat_123');
      expect(serialized['name'], 'Nhạc Trẻ');
      expect(serialized['imageUrl'], 'https://example.com/cat.png');
    });

    test('Artist serialization and deserialization', () {
      final json = {
        'id': 'art_123',
        'name': 'Sơn Tùng M-TP',
        'imageUrl': 'https://example.com/art.png',
      };

      final artist = Artist.fromJson(json);
      expect(artist.id, 'art_123');
      expect(artist.name, 'Sơn Tùng M-TP');
      expect(artist.imageUrl, 'https://example.com/art.png');

      final serialized = artist.toJson();
      expect(serialized['id'], 'art_123');
      expect(serialized['name'], 'Sơn Tùng M-TP');
      expect(serialized['imageUrl'], 'https://example.com/art.png');
    });
  });
}
