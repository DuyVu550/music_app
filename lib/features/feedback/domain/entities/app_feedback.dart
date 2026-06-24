import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_feedback.freezed.dart';

@freezed
abstract class AppFeedback with _$AppFeedback {
  const factory AppFeedback({
    required double rating,
    required String comment,
    @Default('') String contactEmail,
  }) = _AppFeedback;
}
