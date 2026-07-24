import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soframda_ne_eksik/core/utils/moderation_report_confirmation.dart';

void main() {
  Future<void> pumpConfirmationLauncher(
    WidgetTester tester,
    void Function(Future<bool>) onOpened,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                onOpened(
                  confirmModerationReport(
                    context,
                    reason: 'Spam veya dolandırıcılık',
                  ),
                );
              },
              child: const Text('Aç'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Aç'));
    await tester.pumpAndSettle();
  }

  testWidgets('şikâyet son onay olmadan gönderilmez', (tester) async {
    late Future<bool> result;
    await pumpConfirmationLauncher(tester, (value) => result = value);

    expect(find.text('Şikâyeti gönder?'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();

    expect(await result, isFalse);
  });

  testWidgets('açık gönderim onayı true döndürür', (tester) async {
    late Future<bool> result;
    await pumpConfirmationLauncher(tester, (value) => result = value);

    await tester.tap(find.text('Şikâyeti Gönder'));
    await tester.pumpAndSettle();

    expect(await result, isTrue);
  });
}
