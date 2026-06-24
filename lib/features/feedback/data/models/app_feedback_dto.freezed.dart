// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_feedback_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppFeedbackDto {

 double get rating; String get comment; String get contactEmail;
/// Create a copy of AppFeedbackDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppFeedbackDtoCopyWith<AppFeedbackDto> get copyWith => _$AppFeedbackDtoCopyWithImpl<AppFeedbackDto>(this as AppFeedbackDto, _$identity);

  /// Serializes this AppFeedbackDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppFeedbackDto&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rating,comment,contactEmail);

@override
String toString() {
  return 'AppFeedbackDto(rating: $rating, comment: $comment, contactEmail: $contactEmail)';
}


}

/// @nodoc
abstract mixin class $AppFeedbackDtoCopyWith<$Res>  {
  factory $AppFeedbackDtoCopyWith(AppFeedbackDto value, $Res Function(AppFeedbackDto) _then) = _$AppFeedbackDtoCopyWithImpl;
@useResult
$Res call({
 double rating, String comment, String contactEmail
});




}
/// @nodoc
class _$AppFeedbackDtoCopyWithImpl<$Res>
    implements $AppFeedbackDtoCopyWith<$Res> {
  _$AppFeedbackDtoCopyWithImpl(this._self, this._then);

  final AppFeedbackDto _self;
  final $Res Function(AppFeedbackDto) _then;

/// Create a copy of AppFeedbackDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rating = null,Object? comment = null,Object? contactEmail = null,}) {
  return _then(_self.copyWith(
rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppFeedbackDto].
extension AppFeedbackDtoPatterns on AppFeedbackDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppFeedbackDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppFeedbackDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppFeedbackDto value)  $default,){
final _that = this;
switch (_that) {
case _AppFeedbackDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppFeedbackDto value)?  $default,){
final _that = this;
switch (_that) {
case _AppFeedbackDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double rating,  String comment,  String contactEmail)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppFeedbackDto() when $default != null:
return $default(_that.rating,_that.comment,_that.contactEmail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double rating,  String comment,  String contactEmail)  $default,) {final _that = this;
switch (_that) {
case _AppFeedbackDto():
return $default(_that.rating,_that.comment,_that.contactEmail);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double rating,  String comment,  String contactEmail)?  $default,) {final _that = this;
switch (_that) {
case _AppFeedbackDto() when $default != null:
return $default(_that.rating,_that.comment,_that.contactEmail);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppFeedbackDto implements AppFeedbackDto {
  const _AppFeedbackDto({required this.rating, required this.comment, this.contactEmail = ''});
  factory _AppFeedbackDto.fromJson(Map<String, dynamic> json) => _$AppFeedbackDtoFromJson(json);

@override final  double rating;
@override final  String comment;
@override@JsonKey() final  String contactEmail;

/// Create a copy of AppFeedbackDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppFeedbackDtoCopyWith<_AppFeedbackDto> get copyWith => __$AppFeedbackDtoCopyWithImpl<_AppFeedbackDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppFeedbackDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppFeedbackDto&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rating,comment,contactEmail);

@override
String toString() {
  return 'AppFeedbackDto(rating: $rating, comment: $comment, contactEmail: $contactEmail)';
}


}

/// @nodoc
abstract mixin class _$AppFeedbackDtoCopyWith<$Res> implements $AppFeedbackDtoCopyWith<$Res> {
  factory _$AppFeedbackDtoCopyWith(_AppFeedbackDto value, $Res Function(_AppFeedbackDto) _then) = __$AppFeedbackDtoCopyWithImpl;
@override @useResult
$Res call({
 double rating, String comment, String contactEmail
});




}
/// @nodoc
class __$AppFeedbackDtoCopyWithImpl<$Res>
    implements _$AppFeedbackDtoCopyWith<$Res> {
  __$AppFeedbackDtoCopyWithImpl(this._self, this._then);

  final _AppFeedbackDto _self;
  final $Res Function(_AppFeedbackDto) _then;

/// Create a copy of AppFeedbackDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rating = null,Object? comment = null,Object? contactEmail = null,}) {
  return _then(_AppFeedbackDto(
rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
