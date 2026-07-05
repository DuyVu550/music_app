import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_notifier.dart';
import '../../domain/entities/comment.dart';
import '../../data/repositories/comment_repository.dart';

// Stream provider to listen to comments in real-time
final commentsStreamProvider = StreamProvider.family.autoDispose<List<Comment>, String>((ref, songId) {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.getCommentsStream(songId);
});

class CommentController {
  final Ref _ref;

  CommentController(this._ref);

  Future<void> addComment(String songId, String content) async {
    final authState = _ref.read(authNotifierProvider);
    final user = authState.value;
    if (user == null) {
      throw Exception('Vui lòng đăng nhập để bình luận');
    }

    final comment = Comment(
      id: '',
      songId: songId,
      userId: user.id,
      userName: user.name.isNotEmpty ? user.name : 'Người dùng',
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    final repository = _ref.read(commentRepositoryProvider);
    await repository.addComment(songId, comment);
  }

  Future<void> deleteComment(String songId, String commentId) async {
    final repository = _ref.read(commentRepositoryProvider);
    await repository.deleteComment(songId, commentId);
  }
}

final commentControllerProvider = Provider<CommentController>((ref) {
  return CommentController(ref);
});
