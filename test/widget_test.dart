import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:soframda_ne_eksik/main.dart';

void main() {
  testWidgets('StartupErrorApp renders fallback screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const StartupErrorApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.textContaining('Uygulama'), findsOneWidget);
  });
}
