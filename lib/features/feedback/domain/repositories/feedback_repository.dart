import '../entities/app_feedback.dart';

abstract class FeedbackRepository {
  Future<void> submitFeedback(AppFeedback feedback);
}
