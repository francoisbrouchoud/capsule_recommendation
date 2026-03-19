import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:capsule_recommendation/main.dart';

void main() {
  testWidgets('shows chatbot with time in app bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CapsuleRecommendationApp());

    final hourFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Text && RegExp(r'^\d{2}:\d{2}$').hasMatch(widget.data ?? ''),
    );

    expect(hourFinder, findsOneWidget);
    expect(
      find.textContaining('Hello, I will help you find the capsule'),
      findsOneWidget,
    );
    expect(find.text('Start'), findsOneWidget);
  });
}
