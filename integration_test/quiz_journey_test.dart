import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User completes quiz and sees results', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Wait for splash screen to disappear
    await Future.delayed(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 2. Wait for first question to appear
    expect(find.byType(ListTile), findsWidgets);

    // 3. Answer 20 questions
    for (int i = 0; i < 20; i++) {
      // Tap the first answer option for each question
      await tester.tap(find.byKey(const ValueKey('answer_0')));
      await tester.pumpAndSettle();
    }

    // 4. Wait for results screen
    expect(find.text('Quiz Results'), findsOneWidget);

    // 5. Validate score is shown
    expect(find.textContaining('You scored'), findsOneWidget);
  });
}