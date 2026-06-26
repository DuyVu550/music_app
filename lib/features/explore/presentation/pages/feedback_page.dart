import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../features/feedback/presentation/controllers/feedback_notifier.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();

  void _submitFeedback() {
    ref.read(feedbackNotifierProvider.notifier).submitFeedback(
          _rating,
          _commentController.text,
        );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedbackState = ref.watch(feedbackNotifierProvider);

    ref.listen<AsyncValue<void>>(feedbackNotifierProvider, (previous, next) {
      if (!next.isLoading && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cảm ơn bạn đã phản hồi! Ý kiến của bạn đã được ghi nhận.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi phản hồi: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16162A),
        title: const Text('Phản Hồi & Liên Hệ', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá ứng dụng',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Slider(
              value: _rating,
              min: 1.0,
              max: 5.0,
              divisions: 4,
              activeColor: Colors.cyanAccent,
              inactiveColor: Colors.white12,
              label: '${_rating.toInt()} ⭐',
              onChanged: (val) {
                setState(() {
                  _rating = val;
                });
              },
            ),
            Center(
              child: Text(
                'Mức độ hài lòng: ${_rating.toInt()} / 5 sao',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ý kiến đóng góp của bạn',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                hintText: 'Nhập ý kiến đóng góp tại đây...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.cyanAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: feedbackState.isLoading ? null : _submitFeedback,
                child: feedbackState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text('Gửi Phản Hồi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 40),
            const Divider(color: Colors.white12),
            const SizedBox(height: 20),
            const Text(
              'Liên hệ với nhà phát triển',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildContactTile(Icons.email_outlined, 'support@harmonix.com', 'mailto:support@harmonix.com'),
            _buildContactTile(Icons.web, 'https://harmonix-music.web.app', 'https://harmonix-music.web.app'),
            _buildContactTile(Icons.phone, '+84 123 456 789', 'tel:+84123456789'),
            _buildContactTile(Icons.facebook_rounded, 'Facebook: Harmonix Music', 'https://facebook.com/harmonix'),
            _buildContactTile(Icons.forum_rounded, 'Skype: Harmonix Support', 'skype:harmonix.support?chat'),
            _buildContactTile(Icons.chat_bubble_outline_rounded, 'Zalo: 0123 456 789', 'https://zalo.me/0123456789'),
            _buildContactTile(Icons.play_circle_fill_rounded, 'Youtube: Harmonix Studio', 'https://youtube.com/c/harmonix'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String text, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể mở liên kết này'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.cyanAccent, size: 24),
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
