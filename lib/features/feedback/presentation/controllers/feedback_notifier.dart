import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_feedback.dart';
import '../../data/repositories/feedback_repository_impl.dart';

final feedbackNotifierProvider = AsyncNotifierProvider.autoDispose<FeedbackNotifier, void>(() {
  return FeedbackNotifier();
});

class FeedbackNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial state is data(null)
  }

  Future<void> submitFeedback(double rating, String comment) async {
    state = const AsyncLoading();
    
    try {
      final repository = ref.read(feedbackRepositoryProvider);
      final feedback = AppFeedback(rating: rating, comment: comment);
      
      await repository.submitFeedback(feedback);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
