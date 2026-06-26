import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist.freezed.dart';
part 'artist.g.dart';

@freezed
abstract class Artist with _$Artist {
  const factory Artist({
    required String id,
    required String name,
    required String imageUrl,
  }) = _Artist;

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
}
