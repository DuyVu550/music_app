// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlayerState {

 List<Track> get playlist; Track? get currentTrack; bool get isPlaying; Duration get position; Duration get duration; bool get isShuffleModeEnabled; PlayerLoopMode get loopMode;
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerStateCopyWith<PlayerState> get copyWith => _$PlayerStateCopyWithImpl<PlayerState>(this as PlayerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerState&&const DeepCollectionEquality().equals(other.playlist, playlist)&&(identical(other.currentTrack, currentTrack) || other.currentTrack == currentTrack)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isShuffleModeEnabled, isShuffleModeEnabled) || other.isShuffleModeEnabled == isShuffleModeEnabled)&&(identical(other.loopMode, loopMode) || other.loopMode == loopMode));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(playlist),currentTrack,isPlaying,position,duration,isShuffleModeEnabled,loopMode);

@override
String toString() {
  return 'PlayerState(playlist: $playlist, currentTrack: $currentTrack, isPlaying: $isPlaying, position: $position, duration: $duration, isShuffleModeEnabled: $isShuffleModeEnabled, loopMode: $loopMode)';
}


}

/// @nodoc
abstract mixin class $PlayerStateCopyWith<$Res>  {
  factory $PlayerStateCopyWith(PlayerState value, $Res Function(PlayerState) _then) = _$PlayerStateCopyWithImpl;
@useResult
$Res call({
 List<Track> playlist, Track? currentTrack, bool isPlaying, Duration position, Duration duration, bool isShuffleModeEnabled, PlayerLoopMode loopMode
});


$TrackCopyWith<$Res>? get currentTrack;

}
/// @nodoc
class _$PlayerStateCopyWithImpl<$Res>
    implements $PlayerStateCopyWith<$Res> {
  _$PlayerStateCopyWithImpl(this._self, this._then);

  final PlayerState _self;
  final $Res Function(PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playlist = null,Object? currentTrack = freezed,Object? isPlaying = null,Object? position = null,Object? duration = null,Object? isShuffleModeEnabled = null,Object? loopMode = null,}) {
  return _then(_self.copyWith(
playlist: null == playlist ? _self.playlist : playlist // ignore: cast_nullable_to_non_nullable
as List<Track>,currentTrack: freezed == currentTrack ? _self.currentTrack : currentTrack // ignore: cast_nullable_to_non_nullable
as Track?,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,isShuffleModeEnabled: null == isShuffleModeEnabled ? _self.isShuffleModeEnabled : isShuffleModeEnabled // ignore: cast_nullable_to_non_nullable
as bool,loopMode: null == loopMode ? _self.loopMode : loopMode // ignore: cast_nullable_to_non_nullable
as PlayerLoopMode,
  ));
}
/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackCopyWith<$Res>? get currentTrack {
    if (_self.currentTrack == null) {
    return null;
  }

  return $TrackCopyWith<$Res>(_self.currentTrack!, (value) {
    return _then(_self.copyWith(currentTrack: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayerState].
extension PlayerStatePatterns on PlayerState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayerState value)  $default,){
final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayerState value)?  $default,){
final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Track> playlist,  Track? currentTrack,  bool isPlaying,  Duration position,  Duration duration,  bool isShuffleModeEnabled,  PlayerLoopMode loopMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.playlist,_that.currentTrack,_that.isPlaying,_that.position,_that.duration,_that.isShuffleModeEnabled,_that.loopMode);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Track> playlist,  Track? currentTrack,  bool isPlaying,  Duration position,  Duration duration,  bool isShuffleModeEnabled,  PlayerLoopMode loopMode)  $default,) {final _that = this;
switch (_that) {
case _PlayerState():
return $default(_that.playlist,_that.currentTrack,_that.isPlaying,_that.position,_that.duration,_that.isShuffleModeEnabled,_that.loopMode);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Track> playlist,  Track? currentTrack,  bool isPlaying,  Duration position,  Duration duration,  bool isShuffleModeEnabled,  PlayerLoopMode loopMode)?  $default,) {final _that = this;
switch (_that) {
case _PlayerState() when $default != null:
return $default(_that.playlist,_that.currentTrack,_that.isPlaying,_that.position,_that.duration,_that.isShuffleModeEnabled,_that.loopMode);case _:
  return null;

}
}

}

/// @nodoc


class _PlayerState implements PlayerState {
  const _PlayerState({final  List<Track> playlist = const [], this.currentTrack, this.isPlaying = false, this.position = Duration.zero, this.duration = Duration.zero, this.isShuffleModeEnabled = false, this.loopMode = PlayerLoopMode.off}): _playlist = playlist;
  

 final  List<Track> _playlist;
@override@JsonKey() List<Track> get playlist {
  if (_playlist is EqualUnmodifiableListView) return _playlist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_playlist);
}

@override final  Track? currentTrack;
@override@JsonKey() final  bool isPlaying;
@override@JsonKey() final  Duration position;
@override@JsonKey() final  Duration duration;
@override@JsonKey() final  bool isShuffleModeEnabled;
@override@JsonKey() final  PlayerLoopMode loopMode;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayerStateCopyWith<_PlayerState> get copyWith => __$PlayerStateCopyWithImpl<_PlayerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayerState&&const DeepCollectionEquality().equals(other._playlist, _playlist)&&(identical(other.currentTrack, currentTrack) || other.currentTrack == currentTrack)&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.position, position) || other.position == position)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.isShuffleModeEnabled, isShuffleModeEnabled) || other.isShuffleModeEnabled == isShuffleModeEnabled)&&(identical(other.loopMode, loopMode) || other.loopMode == loopMode));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_playlist),currentTrack,isPlaying,position,duration,isShuffleModeEnabled,loopMode);

@override
String toString() {
  return 'PlayerState(playlist: $playlist, currentTrack: $currentTrack, isPlaying: $isPlaying, position: $position, duration: $duration, isShuffleModeEnabled: $isShuffleModeEnabled, loopMode: $loopMode)';
}


}

/// @nodoc
abstract mixin class _$PlayerStateCopyWith<$Res> implements $PlayerStateCopyWith<$Res> {
  factory _$PlayerStateCopyWith(_PlayerState value, $Res Function(_PlayerState) _then) = __$PlayerStateCopyWithImpl;
@override @useResult
$Res call({
 List<Track> playlist, Track? currentTrack, bool isPlaying, Duration position, Duration duration, bool isShuffleModeEnabled, PlayerLoopMode loopMode
});


@override $TrackCopyWith<$Res>? get currentTrack;

}
/// @nodoc
class __$PlayerStateCopyWithImpl<$Res>
    implements _$PlayerStateCopyWith<$Res> {
  __$PlayerStateCopyWithImpl(this._self, this._then);

  final _PlayerState _self;
  final $Res Function(_PlayerState) _then;

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playlist = null,Object? currentTrack = freezed,Object? isPlaying = null,Object? position = null,Object? duration = null,Object? isShuffleModeEnabled = null,Object? loopMode = null,}) {
  return _then(_PlayerState(
playlist: null == playlist ? _self._playlist : playlist // ignore: cast_nullable_to_non_nullable
as List<Track>,currentTrack: freezed == currentTrack ? _self.currentTrack : currentTrack // ignore: cast_nullable_to_non_nullable
as Track?,isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,isShuffleModeEnabled: null == isShuffleModeEnabled ? _self.isShuffleModeEnabled : isShuffleModeEnabled // ignore: cast_nullable_to_non_nullable
as bool,loopMode: null == loopMode ? _self.loopMode : loopMode // ignore: cast_nullable_to_non_nullable
as PlayerLoopMode,
  ));
}

/// Create a copy of PlayerState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackCopyWith<$Res>? get currentTrack {
    if (_self.currentTrack == null) {
    return null;
  }

  return $TrackCopyWith<$Res>(_self.currentTrack!, (value) {
    return _then(_self.copyWith(currentTrack: value));
  });
}
}

// dart format on
