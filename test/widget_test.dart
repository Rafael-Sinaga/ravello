import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ravello/main.dart';

void main() {
  testWidgets('App runs without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RavelloApp());

    // Verify that the app title is correct.
    expect(find.text('Ravello E-Commerce'), findsNothing);

    // Verify MaterialApp structure.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
