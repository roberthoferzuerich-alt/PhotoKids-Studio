import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photokids_studio/shared/widgets/kid_button.dart';

void main() {
  group('KidButton Widget Tests', () {
    testWidgets('Renders label and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KidButton(
              label: 'Hier drücken! 🎈',
              icon: const Icon(Icons.star),
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Hier drücken! 🎈'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);

      await tester.tap(find.byType(KidButton));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
