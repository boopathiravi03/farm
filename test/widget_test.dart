import 'package:flutter_test/flutter_test.dart';
import 'package:farm_trading/main.dart';

void main() {
  testWidgets('FarmTradingApp launches and shows intro/role selection flow', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FarmTradingApp());

    // Verify that Farm Trading title appears on startup
    expect(find.text('Farm Trading'), findsWidgets);

    // Trigger frame pump
    await tester.pumpAndSettle();

    // Verify navigation smoothly lands on Role Selection screen
    expect(find.text('Welcome 👋'), findsOneWidget);
  });
}
