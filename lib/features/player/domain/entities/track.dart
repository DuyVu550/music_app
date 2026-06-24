import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';
part 'track.g.dart';

@freezed
abstract class Track with _$Track {
  const factory Track({
    required String id,
    required String title,
    required String url,
    required String albumId,
    required List<String> artistIds,
    @Default(0) int durationMs,
    @Default(false) bool isExplicit,
    String? coverUrl,
    @Default(0) int listeners,
  }) = _Track;

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);
}
