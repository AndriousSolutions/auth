import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart'
    show IntegrationTestWidgetsFlutterBinding;

void main() => testMyApp();

/// Also called in package's own testing file, test/widget_test.dart
void testMyApp() {
  //
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Registers a function to be run once after all tests.
  /// Be sure the close the app after all the testing.
  tearDownAll(() {});

  /// Define a test. The TestWidgets function also provides a WidgetTester
  /// to work with. The WidgetTester allows you to build and interact
  /// with widgets in the test environment.
  testWidgets('auth testing', (WidgetTester tester) async {
//
  });
}
