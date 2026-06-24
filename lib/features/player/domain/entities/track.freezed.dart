// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Track {

 String get id; String get title; String get url; String get albumId; List<String> get artistIds; int get durationMs; bool get isExplicit; String? get coverUrl; int get listeners;
/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackCopyWith<Track> get copyWith => _$TrackCopyWithImpl<Track>(this as Track, _$identity);

  /// Serializes this Track to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Track&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.albumId, albumId) || other.albumId == albumId)&&const DeepCollectionEquality().equals(other.artistIds, artistIds)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.isExplicit, isExplicit) || other.isExplicit == isExplicit)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.listeners, listeners) || other.listeners == listeners));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,url,albumId,const DeepCollectionEquality().hash(artistIds),durationMs,isExplicit,coverUrl,listeners);

@override
String toString() {
  return 'Track(id: $id, title: $title, url: $url, albumId: $albumId, artistIds: $artistIds, durationMs: $durationMs, isExplicit: $isExplicit, coverUrl: $coverUrl, listeners: $listeners)';
}


}

/// @nodoc
abstract mixin class $TrackCopyWith<$Res>  {
  factory $TrackCopyWith(Track value, $Res Function(Track) _then) = _$TrackCopyWithImpl;
@useResult
$Res call({
 String id, String title, String url, String albumId, List<String> artistIds, int durationMs, bool isExplicit, String? coverUrl, int listeners
});




}
/// @nodoc
class _$TrackCopyWithImpl<$Res>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._self, this._then);

  final Track _self;
  final $Res Function(Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? url = null,Object? albumId = null,Object? artistIds = null,Object? durationMs = null,Object? isExplicit = null,Object? coverUrl = freezed,Object? listeners = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,albumId: null == albumId ? _self.albumId : albumId // ignore: cast_nullable_to_non_nullable
as String,artistIds: null == artistIds ? _self.artistIds : artistIds // ignore: cast_nullable_to_non_nullable
as List<String>,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,isExplicit: null == isExplicit ? _self.isExplicit : isExplicit // ignore: cast_nullable_to_non_nullable
as bool,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,listeners: null == listeners ? _self.listeners : listeners // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Track].
extension TrackPatterns on Track {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Track value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Track value)  $default,){
final _that = this;
switch (_that) {
case _Track():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Track value)?  $default,){
final _that = this;
switch (_that) {
case _Track() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String url,  String albumId,  List<String> artistIds,  int durationMs,  bool isExplicit,  String? coverUrl,  int listeners)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.albumId,_that.artistIds,_that.durationMs,_that.isExplicit,_that.coverUrl,_that.listeners);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String url,  String albumId,  List<String> artistIds,  int durationMs,  bool isExplicit,  String? coverUrl,  int listeners)  $default,) {final _that = this;
switch (_that) {
case _Track():
return $default(_that.id,_that.title,_that.url,_that.albumId,_that.artistIds,_that.durationMs,_that.isExplicit,_that.coverUrl,_that.listeners);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String url,  String albumId,  List<String> artistIds,  int durationMs,  bool isExplicit,  String? coverUrl,  int listeners)?  $default,) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.albumId,_that.artistIds,_that.durationMs,_that.isExplicit,_that.coverUrl,_that.listeners);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Track implements Track {
  const _Track({required this.id, required this.title, required this.url, required this.albumId, required final  List<String> artistIds, this.durationMs = 0, this.isExplicit = false, this.coverUrl, this.listeners = 0}): _artistIds = artistIds;
  factory _Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

@override final  String id;
@override final  String title;
@override final  String url;
@override final  String albumId;
 final  List<String> _artistIds;
@override List<String> get artistIds {
  if (_artistIds is EqualUnmodifiableListView) return _artistIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_artistIds);
}

@override@JsonKey() final  int durationMs;
@override@JsonKey() final  bool isExplicit;
@override final  String? coverUrl;
@override@JsonKey() final  int listeners;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackCopyWith<_Track> get copyWith => __$TrackCopyWithImpl<_Track>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Track&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.albumId, albumId) || other.albumId == albumId)&&const DeepCollectionEquality().equals(other._artistIds, _artistIds)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.isExplicit, isExplicit) || other.isExplicit == isExplicit)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.listeners, listeners) || other.listeners == listeners));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,url,albumId,const DeepCollectionEquality().hash(_artistIds),durationMs,isExplicit,coverUrl,listeners);

@override
String toString() {
  return 'Track(id: $id, title: $title, url: $url, albumId: $albumId, artistIds: $artistIds, durationMs: $durationMs, isExplicit: $isExplicit, coverUrl: $coverUrl, listeners: $listeners)';
}


}

/// @nodoc
abstract mixin class _$TrackCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$TrackCopyWith(_Track value, $Res Function(_Track) _then) = __$TrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String url, String albumId, List<String> artistIds, int durationMs, bool isExplicit, String? coverUrl, int listeners
});




}
/// @nodoc
class __$TrackCopyWithImpl<$Res>
    implements _$TrackCopyWith<$Res> {
  __$TrackCopyWithImpl(this._self, this._then);

  final _Track _self;
  final $Res Function(_Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? url = null,Object? albumId = null,Object? artistIds = null,Object? durationMs = null,Object? isExplicit = null,Object? coverUrl = freezed,Object? listeners = null,}) {
  return _then(_Track(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,albumId: null == albumId ? _self.albumId : albumId // ignore: cast_nullable_to_non_nullable
as String,artistIds: null == artistIds ? _self._artistIds : artistIds // ignore: cast_nullable_to_non_nullable
as List<String>,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,isExplicit: null == isExplicit ? _self.isExplicit : isExplicit // ignore: cast_nullable_to_non_nullable
as bool,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,listeners: null == listeners ? _self.listeners : listeners // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
