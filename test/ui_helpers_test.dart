import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soframda_ne_eksik/core/utils/ui_helpers.dart';

void main() {
  testWidgets(
    'credit animation only closes its own route when a broadcast is visible',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showCreditAnimation(context, '+5');
                  showModalBottomSheet<void>(
                    context: context,
                    isDismissible: false,
                    enableDrag: false,
                    builder: (_) => const Text('Yönetici duyurusu'),
                  );
                },
                child: const Text('Başlat'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Başlat'));
      await tester.pump();
      expect(find.text('Yönetici duyurusu'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('Yönetici duyurusu'), findsOneWidget);
      expect(find.text('+5'), findsNothing);
    },
  );
}
