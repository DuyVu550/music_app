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
                              fb.userEmail,
                              style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              ref.read(adminControllerProvider).deleteFeedback(fb.id);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(fb.content, style: const TextStyle(color: Colors.white, fontSize: 16)),
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
