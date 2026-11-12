import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kpcosmo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KPAstrologyApp());

    // Verify that the app builds without errors.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
