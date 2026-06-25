import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_feedback_dto.dart';

abstract class FeedbackRemoteDataSource {
  Future<void> submitFeedback(AppFeedbackDto feedbackDto);
}

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final FirebaseFirestore _firestore;

  FeedbackRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> submitFeedback(AppFeedbackDto feedbackDto) async {
    final docRef = _firestore.collection('feedbacks').doc();
    
    // Convert DTO to JSON and add server timestamp if createdAt is null
    final data = feedbackDto.toJson();
    data['id'] = docRef.id;
    if (data['createdAt'] == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
    } else {
      // Ensure createdAt is stored as Timestamp in Firestore
      data['createdAt'] = Timestamp.fromDate(feedbackDto.createdAt!);
    }

    await docRef.set(data);
  }
}
