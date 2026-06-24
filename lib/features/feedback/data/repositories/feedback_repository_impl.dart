import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_feedback.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../datasources/feedback_remote_data_source.dart';
import '../models/app_feedback_dto.dart';

final feedbackRemoteDataSourceProvider = Provider<FeedbackRemoteDataSource>((ref) {
  return FeedbackRemoteDataSourceImpl();
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final dataSource = ref.watch(feedbackRemoteDataSourceProvider);
  return FeedbackRepositoryImpl(remoteDataSource: dataSource);
});

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;

  FeedbackRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> submitFeedback(AppFeedback feedback) async {
    final dto = AppFeedbackDto.fromEntity(feedback);
    await remoteDataSource.submitFeedback(dto);
  }
}
