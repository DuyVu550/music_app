// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_feedback_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppFeedbackDto _$AppFeedbackDtoFromJson(Map<String, dynamic> json) =>
    _AppFeedbackDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      contactEmail: json['contactEmail'] as String? ?? '',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppFeedbackDtoToJson(_AppFeedbackDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'rating': instance.rating,
      'comment': instance.comment,
      'contactEmail': instance.contactEmail,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
