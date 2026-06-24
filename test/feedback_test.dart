import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:music_app/features/feedback/domain/entities/app_feedback.dart';
import 'package:music_app/features/feedback/domain/repositories/feedback_repository.dart';
import 'package:music_app/features/explore/presentation/pages/feedback_page.dart';
import 'package:music_app/features/feedback/presentation/controllers/feedback_notifier.dart';
import 'package:music_app/features/feedback/data/repositories/feedback_repository_impl.dart';

class FakeFeedbackRepository implements FeedbackRepository {
  AppFeedback? lastSubmittedFeedback;
  bool shouldThrow = false;
  int callCount = 0;
  Completer<void>? completer;

  @override
  Future<void> submitFeedback(AppFeedback feedback) async {
    callCount++;
    if (completer != null) {
      await completer!.future;
    }
    if (shouldThrow) {
      throw Exception('Database submission failed');
    }
    lastSubmittedFeedback = feedback;
  }
}

class FakeUrlLauncher extends UrlLauncherPlatform
    with MockPlatformInterfaceMixin {
  String? launchedUrl;
  bool canLaunchReturnValue = true;
  bool launchReturnValue = true;
  LaunchOptions? lastOptions;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async {
    return canLaunchReturnValue;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launchedUrl = url;
    lastOptions = options;
    return launchReturnValue;
  }
}

void main() {
  group('FeedbackNotifier Tests', () {
    test('Initial state is AsyncData(null)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(feedbackNotifierProvider);
      expect(state, const AsyncData<void>(null));
    });

    test('submitFeedback updates state to loading then data on success', () async {
      final repository = FakeFeedbackRepository();
      final container = ProviderContainer(
        overrides: [
          feedbackRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(feedbackNotifierProvider.notifier);
      
      // Submit feedback asynchronously
      final future = notifier.submitFeedback(4.0, 'Rất tốt!');
      
      // Immediately, it should be in loading state
      expect(container.read(feedbackNotifierProvider).isLoading, true);
      
      await future;

      // On completion, state should be back to AsyncData(null)
      expect(container.read(feedbackNotifierProvider), const AsyncData<void>(null));
      expect(repository.callCount, 1);
      expect(repository.lastSubmittedFeedback?.rating, 4.0);
      expect(repository.lastSubmittedFeedback?.comment, 'Rất tốt!');
    });

    test('submitFeedback updates state to error on failure', () async {
      final repository = FakeFeedbackRepository()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [
          feedbackRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(feedbackNotifierProvider.notifier);
      await notifier.submitFeedback(3.0, 'Tệ!');

      expect(container.read(feedbackNotifierProvider).hasError, true);
      expect(repository.callCount, 1);
    });
  });

  group('FeedbackPage Widget Tests', () {
    late FakeFeedbackRepository fakeRepository;
    late FakeUrlLauncher fakeUrlLauncher;

    setUp(() {
      fakeRepository = FakeFeedbackRepository();
      fakeUrlLauncher = FakeUrlLauncher();
      UrlLauncherPlatform.instance = fakeUrlLauncher;
    });

    Widget createFeedbackPage() {
      return ProviderScope(
        overrides: [
          feedbackRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: const MaterialApp(
          home: FeedbackPage(),
        ),
      );
    }

    testWidgets('renders all widgets correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createFeedbackPage());

      expect(find.text('Phản Hồi & Liên Hệ'), findsOneWidget);
      expect(find.text('Đánh giá ứng dụng'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('Ý kiến đóng góp của bạn'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Gửi Phản Hồi'), findsOneWidget);
    });

    testWidgets('submitting feedback calls repository and pops navigator', (WidgetTester tester) async {
      final completer = Completer<void>();
      fakeRepository.completer = completer;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            feedbackRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackPage()),
                ),
                child: const Text('Go to Feedback'),
              ),
            ),
          ),
        ),
      );

      // Open page
      await tester.tap(find.text('Go to Feedback'));
      await tester.pumpAndSettle();

      // Enter feedback comment
      await tester.enterText(find.byType(TextField), 'Ứng dụng tuyệt vời!');
      await tester.pump();

      // Tap submit button
      await tester.tap(find.text('Gửi Phản Hồi'));
      // Wait for it to trigger submission and update UI to loading
      await tester.pump();

      // Verify Loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the completer to finish repository submitFeedback
      completer.complete();
      
      // Pump once to allow the future to complete and the page to rebuild/pop
      await tester.pump();
      // Pump again to start showing the SnackBar
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that snackbar was shown
      expect(find.text('Cảm ơn bạn đã phản hồi! Ý kiến của bạn đã được ghi nhận.'), findsOneWidget);

      // Wait for the navigation transition and snackbar animation to complete fully
      await tester.pumpAndSettle();

      // Verify repository was called
      expect(fakeRepository.callCount, 1);
      expect(fakeRepository.lastSubmittedFeedback?.rating, 5.0); // Default rating
      expect(fakeRepository.lastSubmittedFeedback?.comment, 'Ứng dụng tuyệt vời!');

      // Verify we popped back to main page
      expect(find.byType(FeedbackPage), findsNothing);
    });

    testWidgets('contact tiles launch correct URLs when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createFeedbackPage());

      // 1. Test Email Tile
      final emailTile = find.text('support@harmonix.com');
      expect(emailTile, findsOneWidget);
      await tester.ensureVisible(emailTile);
      await tester.pumpAndSettle();
      await tester.tap(emailTile);
      await tester.pumpAndSettle();
      expect(fakeUrlLauncher.launchedUrl, 'mailto:support@harmonix.com');

      // 2. Test Website Tile
      final webTile = find.text('https://harmonix-music.web.app');
      expect(webTile, findsOneWidget);
      await tester.ensureVisible(webTile);
      await tester.pumpAndSettle();
      await tester.tap(webTile);
      await tester.pumpAndSettle();
      expect(fakeUrlLauncher.launchedUrl, 'https://harmonix-music.web.app');

      // 3. Test Phone Tile
      final phoneTile = find.text('+84 123 456 789');
      expect(phoneTile, findsOneWidget);
      await tester.ensureVisible(phoneTile);
      await tester.pumpAndSettle();
      await tester.tap(phoneTile);
      await tester.pumpAndSettle();
      expect(fakeUrlLauncher.launchedUrl, 'tel:+84123456789');
    });

    testWidgets('shows snackbar when contact tile link fails to launch', (WidgetTester tester) async {
      fakeUrlLauncher.canLaunchReturnValue = false;
      await tester.pumpWidget(createFeedbackPage());

      final emailTile = find.text('support@harmonix.com');
      await tester.ensureVisible(emailTile);
      await tester.pumpAndSettle();
      await tester.tap(emailTile);
      await tester.pump(); // Start opening and showing snackbar
      await tester.pump(const Duration(milliseconds: 100)); // allow snackbar animation

      expect(find.text('Không thể mở liên kết này'), findsOneWidget);
      
      // Clean up snackbar
      await tester.pumpAndSettle();
    });
  });
}
