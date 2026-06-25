import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_feedback.freezed.dart';

@freezed
abstract class AppFeedback with _$AppFeedback {
  const factory AppFeedback({
    String? id,
    String? userId,
    required double rating,
    required String comment,
    @Default('') String contactEmail,
    DateTime? createdAt,
  }) = _AppFeedback;
}
