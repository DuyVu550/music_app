// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_feedback.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppFeedback {

 double get rating; String get comment; String get contactEmail;
/// Create a copy of AppFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppFeedbackCopyWith<AppFeedback> get copyWith => _$AppFeedbackCopyWithImpl<AppFeedback>(this as AppFeedback, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppFeedback&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail));
}


@override
int get hashCode => Object.hash(runtimeType,rating,comment,contactEmail);

@override
String toString() {
  return 'AppFeedback(rating: $rating, comment: $comment, contactEmail: $contactEmail)';
}


}

/// @nodoc
abstract mixin class $AppFeedbackCopyWith<$Res>  {
  factory $AppFeedbackCopyWith(AppFeedback value, $Res Function(AppFeedback) _then) = _$AppFeedbackCopyWithImpl;
@useResult
$Res call({
 double rating, String comment, String contactEmail
});




}
/// @nodoc
class _$AppFeedbackCopyWithImpl<$Res>
    implements $AppFeedbackCopyWith<$Res> {
  _$AppFeedbackCopyWithImpl(this._self, this._then);

  final AppFeedback _self;
  final $Res Function(AppFeedback) _then;

/// Create a copy of AppFeedback
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


/// Adds pattern-matching-related methods to [AppFeedback].
extension AppFeedbackPatterns on AppFeedback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppFeedback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppFeedback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppFeedback value)  $default,){
final _that = this;
switch (_that) {
case _AppFeedback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppFeedback value)?  $default,){
final _that = this;
switch (_that) {
case _AppFeedback() when $default != null:
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
case _AppFeedback() when $default != null:
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
case _AppFeedback():
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
case _AppFeedback() when $default != null:
return $default(_that.rating,_that.comment,_that.contactEmail);case _:
  return null;

}
}

}

/// @nodoc


class _AppFeedback implements AppFeedback {
  const _AppFeedback({required this.rating, required this.comment, this.contactEmail = ''});
  

@override final  double rating;
@override final  String comment;
@override@JsonKey() final  String contactEmail;

/// Create a copy of AppFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppFeedbackCopyWith<_AppFeedback> get copyWith => __$AppFeedbackCopyWithImpl<_AppFeedback>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppFeedback&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.contactEmail, contactEmail) || other.contactEmail == contactEmail));
}


@override
int get hashCode => Object.hash(runtimeType,rating,comment,contactEmail);

@override
String toString() {
  return 'AppFeedback(rating: $rating, comment: $comment, contactEmail: $contactEmail)';
}


}

/// @nodoc
abstract mixin class _$AppFeedbackCopyWith<$Res> implements $AppFeedbackCopyWith<$Res> {
  factory _$AppFeedbackCopyWith(_AppFeedback value, $Res Function(_AppFeedback) _then) = __$AppFeedbackCopyWithImpl;
@override @useResult
$Res call({
 double rating, String comment, String contactEmail
});




}
/// @nodoc
class __$AppFeedbackCopyWithImpl<$Res>
    implements _$AppFeedbackCopyWith<$Res> {
  __$AppFeedbackCopyWithImpl(this._self, this._then);

  final _AppFeedback _self;
  final $Res Function(_AppFeedback) _then;

/// Create a copy of AppFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rating = null,Object? comment = null,Object? contactEmail = null,}) {
  return _then(_AppFeedback(
rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,contactEmail: null == contactEmail ? _self.contactEmail : contactEmail // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
