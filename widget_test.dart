import 'package:flutter_test/flutter_test.dart';
import 'package:fitmate_ai/main.dart';

void main() {
  testWidgets('FitMate app launches', (tester) async {
    await tester.pumpWidget(const FitMateApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('FitMate AI'), findsOneWidget);
  });
}
