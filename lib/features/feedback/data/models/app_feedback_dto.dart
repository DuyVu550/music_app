import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/app_feedback.dart';

part 'app_feedback_dto.freezed.dart';
part 'app_feedback_dto.g.dart';

@freezed
abstract class AppFeedbackDto with _$AppFeedbackDto {
  const factory AppFeedbackDto({
    required double rating,
    required String comment,
    @Default('') String contactEmail,
  }) = _AppFeedbackDto;

  factory AppFeedbackDto.fromJson(Map<String, dynamic> json) => _$AppFeedbackDtoFromJson(json);

  factory AppFeedbackDto.fromEntity(AppFeedback entity) {
    return AppFeedbackDto(
      rating: entity.rating,
      comment: entity.comment,
      contactEmail: entity.contactEmail,
    );
  }
}
