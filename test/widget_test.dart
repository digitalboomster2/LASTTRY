import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:savvy_bee/main.dart';

void main() {
  testWidgets('Savvy Bee app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SavvyBeeApp());

    // Verify that the app builds without errors
    expect(find.byType(SavvyBeeApp), findsOneWidget);
  });
}
