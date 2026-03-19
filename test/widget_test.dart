import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capsule_recommendation/main.dart';

void main() {
  testWidgets('affiche le chatbot avec heure en barre de navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CapsuleRecommendationApp());

    final hourFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Text && RegExp(r'^\d{2}:\d{2}$').hasMatch(widget.data ?? ''),
    );

    expect(hourFinder, findsOneWidget);
    expect(
      find.textContaining('Bonjour, je vais vous aider à trouver la capsule'),
      findsOneWidget,
    );
    expect(find.text('Commencer'), findsOneWidget);
  });
}
