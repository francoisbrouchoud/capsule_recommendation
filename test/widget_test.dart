import 'package:flutter_test/flutter_test.dart';

import 'package:capsule_recommendation/main.dart';

void main() {
  testWidgets('affiche le chatbot de recommandation de capsules',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CapsuleRecommendationApp());

    expect(find.text('Nespresso Capsule Assistant'), findsOneWidget);
    expect(
      find.textContaining('Bonjour, je vais vous aider à trouver la capsule'),
      findsOneWidget,
    );
    expect(find.text('Commencer'), findsOneWidget);
  });
}
