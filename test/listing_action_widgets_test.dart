import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soframda_ne_eksik/presentation/widgets/listing_action_widgets.dart';

void main() {
  testWidgets('review reminder presents its message and icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ListingReviewReminder(
            message: 'Eşleştikten sonra değerlendirme yapmayı unutma.',
          ),
        ),
      ),
    );

    expect(
      find.text('Eşleştikten sonra değerlendirme yapmayı unutma.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
  });

  testWidgets('report button stays compact and handles taps', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompactListingReportButton(
            label: 'İlanı Şikâyet Et',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    final button = find.byType(OutlinedButton);
    final buttonSize = tester.getSize(button);

    expect(buttonSize.height, greaterThanOrEqualTo(48));
    expect(buttonSize.height, lessThan(64));
    expect(find.text('İlanı Şikâyet Et'), findsOneWidget);

    await tester.tap(button);
    await tester.pump();

    expect(pressed, isTrue);
  });
}
