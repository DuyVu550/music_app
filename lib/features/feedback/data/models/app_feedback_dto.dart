import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/app_feedback.dart';

part 'app_feedback_dto.freezed.dart';
part 'app_feedback_dto.g.dart';

@freezed
abstract class AppFeedbackDto with _$AppFeedbackDto {
  const factory AppFeedbackDto({
    String? id,
    String? userId,
    required double rating,
    required String comment,
    @Default('') String contactEmail,
    DateTime? createdAt,
  }) = _AppFeedbackDto;

  const AppFeedbackDto._();

  factory AppFeedbackDto.fromJson(Map<String, dynamic> json) => _$AppFeedbackDtoFromJson(json);

  factory AppFeedbackDto.fromEntity(AppFeedback entity) {
    return AppFeedbackDto(
      id: entity.id,
      userId: entity.userId,
      rating: entity.rating,
      comment: entity.comment,
      contactEmail: entity.contactEmail,
      createdAt: entity.createdAt,
    );
  }
  
  AppFeedback toEntity() {
    return AppFeedback(
      id: id,
      userId: userId,
      rating: rating,
      comment: comment,
      contactEmail: contactEmail,
      createdAt: createdAt,
    );
  }
}
