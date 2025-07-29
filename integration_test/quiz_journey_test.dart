// Integration test: Full user journey for SimpleFlutterFlashcards

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  late FlutterDriver driver;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    if (driver != null) {
      await driver.close();
    }
  });

  test('User completes quiz and sees results', () async {
    // 1. Wait for splash screen
    await driver.waitFor(find.byType('SplashScreen'));

    // 2. Wait for first question to appear
    await driver.waitFor(find.byType('QuestionsPage'));
    await driver.waitFor(find.byType('ListTile'));

    // 3. Answer 20 questions
    for (int i = 0; i < 20; i++) {
      // Verify progress indicator is visible
      final progressText = 'Question ${i + 1} of 20';
      await driver.waitFor(find.text(progressText));

      // Tap the first answer option for each question using its ValueKey
      await driver.tap(find.byValueKey('answer_0'));
      // Wait for next question or results
      if (i < 19) {
        await driver.waitFor(find.byType('ListTile'));
      }
    }

    // 4. Wait for results screen
    await driver.waitFor(find.text('Quiz Results'));

    // 5. Validate score is shown
    // Score text is like 'You scored X out of Y'
    bool scoreFound = false;
    for (int correct = 0; correct <= 20; correct++) {
      final scoreText = 'You scored $correct out of 20';
      try {
        final scoreTextFinder = find.text(scoreText);
        await driver.waitFor(scoreTextFinder, timeout: const Duration(milliseconds: 500));
        scoreFound = true;
        break;
      } catch (e) {
        // Try next possible score value
      }
    }
    expect(scoreFound, true, reason: 'Score should be visible on results screen');
  });
}
