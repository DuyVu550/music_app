import '../models/app_feedback_dto.dart';

abstract class FeedbackRemoteDataSource {
  Future<void> submitFeedback(AppFeedbackDto feedbackDto);
}

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  @override
  Future<void> submitFeedback(AppFeedbackDto feedbackDto) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Here we would normally use ApiClient or Dio to send data:
    // await apiClient.post('/api/feedbacks', data: feedbackDto.toJson());
    
    // Simulated successful submission
    return;
  }
}
