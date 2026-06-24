import 'package:freezed_annotation/freezed_annotation.dart';
import 'track.dart';

part 'player_state.freezed.dart';

@freezed
abstract class PlayerState with _$PlayerState {
  const factory PlayerState({
    @Default([]) List<Track> playlist,
    Track? currentTrack,
    @Default(false) bool isPlaying,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
  }) = _PlayerState;
}
