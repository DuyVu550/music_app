import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist.freezed.dart';
part 'playlist.g.dart';

@freezed
abstract class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String name,
    required String userId,
    @Default([]) List<String> trackIds,
    String? description,
    String? coverUrl,
    String? createdAt,
  }) = _Playlist;

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);
}
