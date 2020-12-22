import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:testfairy_flutter_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized()
          as IntegrationTestWidgetsFlutterBinding;

  Finder findByValueKey(String keyName) {
    return find.byKey(Key(keyName));
  }

  final Finder errorTextFinder = findByValueKey('errorMessage');
  final Finder testingFinder = findByValueKey('testing');
  final Finder notTestingFinder = findByValueKey('notTesting');

  setUpAll(() async {});

  // Helper test builder:
  // 1. Scrolls and finds a button that runs a test case.
  // 2. Before waiting the test to complete, allows you to inject additional logic.
  // 3. Waits for test completion.
  // 4. Asserts failure if error is found.
  void testfairyTest(
      String testName, Finder testButtonFinder, Function testCaseFunction,
      {bool scroll = true}) {
    testWidgets(testName, (WidgetTester tester) async {
      app.main();
      binding.ensureVisualUpdate();
      await binding.waitUntilFirstFrameRasterized;
      await tester.pumpAndSettle();

      if (scroll) {
        await tester.scrollUntilVisible(testButtonFinder, 40,
//            scrollable: scrollerFinder,
            maxScrolls: 100,
            duration: const Duration(seconds: 10));
      }

      expect(tester.any(testButtonFinder), true);
      await tester.tap(testButtonFinder);

      print("Delaying...");
      await Future<void>.delayed(Duration(seconds: 2));
      await tester.pumpAndSettle();
      print("Delayed");

      await testCaseFunction();

      bool testingFinderStillFinds = tester.any(testingFinder);
      for (int i = 0; i < 30; i++) {
        testingFinderStillFinds = tester.any(testingFinder);

        if (!testingFinderStillFinds) {
          break;
        }

        await Future<void>.delayed(const Duration(seconds: 1));
        binding.ensureVisualUpdate();
        await tester.pumpAndSettle();
      }

      binding.ensureVisualUpdate();
      await tester.pumpAndSettle();

      expect(tester.any(testingFinder), false);
      expect(tester.any(notTestingFinder), true);

      expect(tester.any(errorTextFinder), true);
      tester.element(errorTextFinder);

      final String x =
          (errorTextFinder.evaluate().single.widget as Text).data ??
              'No error yet';
      print('$testName: $x');

      expect(x, 'No error yet.');
    });
  }

  // Helper test builder:
  // 1. Scrolls and finds a button that runs a test case.
  // 2. Waits for test completion.
  // 3. Asserts failure if error is found.
  void testfairyTestSimple(String testName, Finder testButtonFinder,
      {bool scroll = true}) {
    testfairyTest(testName, testButtonFinder, () async {}, scroll: scroll);
  }

  // Test cases (implement a button that starts the test on ui, find and tap it with a finder)
  testfairyTestSimple('Lifecycle Test', findByValueKey('lifecycleTests'),
      scroll: false);
  testfairyTestSimple(
      'Server Endpoint Test', findByValueKey('serverEndpointTest'));
  testfairyTestSimple('Feedback Tests', findByValueKey('feedbackTests'));
  testfairyTestSimple(
      'Feedback Shake Test', findByValueKey('feedbackShakeTest'));
  testfairyTestSimple('Version Test', findByValueKey('versionTest'));
  testfairyTestSimple('Session Url Test', findByValueKey('sessionUrlTest'));
  testfairyTestSimple(
      'Add Checkpoint Test', findByValueKey('addCheckpointTest'));
  testfairyTestSimple('Add Event Test', findByValueKey('addEventTest'));
  testfairyTestSimple('Identity Tests', findByValueKey('identityTests'));
  testfairyTestSimple('Log Tests', findByValueKey('logTests'));
  testfairyTestSimple(
      'Developer Options Tests', findByValueKey('developerOptionsTests'));
  testfairyTestSimple(
      'Disable Auto Update Tests', findByValueKey('disableAutoUpdateTests'));
//    testfairyTestSimple('Feedback Options Tests', findByValueKey('feedbackOptionsTests'));
}
