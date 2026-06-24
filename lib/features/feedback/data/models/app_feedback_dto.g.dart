// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_feedback_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppFeedbackDto _$AppFeedbackDtoFromJson(Map<String, dynamic> json) =>
    _AppFeedbackDto(
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      contactEmail: json['contactEmail'] as String? ?? '',
    );

Map<String, dynamic> _$AppFeedbackDtoToJson(_AppFeedbackDto instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'comment': instance.comment,
      'contactEmail': instance.contactEmail,
    };
