import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/admin_controller.dart';
import 'package:intl/intl.dart';

class FeedbackManagementPage extends ConsumerWidget {
  const FeedbackManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsyncValue = ref.watch(feedbackStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: feedbackAsyncValue.when(
        data: (feedbacks) {
          if (feedbacks.isEmpty) {
            return const Center(
              child: Text('Chưa có phản hồi nào.', style: TextStyle(color: Colors.white54)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final fb = feedbacks[index];
              return Card(
                color: Colors.white.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              fb.contactEmail.isNotEmpty ? fb.contactEmail : 'Ẩn danh',
                              style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orangeAccent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  fb.rating.toStringAsFixed(1),
                                  style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF1A1A2E),
                                  title: const Text('Xác nhận xoá', style: TextStyle(color: Colors.white)),
                                  content: const Text('Bạn có chắc chắn muốn xoá phản hồi này không?', style: TextStyle(color: Colors.white70)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ref.read(adminControllerProvider).deleteFeedback(fb.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Đã xoá phản hồi'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      child: const Text('Xoá', style: TextStyle(color: Colors.redAccent)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(fb.comment, style: const TextStyle(color: Colors.white, fontSize: 16)),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(fb.createdAt),
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
        error: (err, stack) => Center(child: Text('Lỗi: $err', style: const TextStyle(color: Colors.redAccent))),
      ),
    );
  }
}
