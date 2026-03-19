import 'package:flutter_test/flutter_test.dart';

import 'package:capsule_recommendation/main.dart';

void main() {
  testWidgets('affiche des suggestions de café', (WidgetTester tester) async {
    await tester.pumpWidget(const CafeApp());

    expect(find.text('Ton café du jour'), findsOneWidget);
    expect(find.text('Espresso'), findsOneWidget);
    expect(find.text('Cappuccino'), findsOneWidget);
  });
}
