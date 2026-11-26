import 'package:flutter_test/flutter_test.dart';
import 'package:fitmate_ai/main.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const FitMateApp());
    expect(find.text('FitMate AI 💪'), findsOneWidget);
  });
}
