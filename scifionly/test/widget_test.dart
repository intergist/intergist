import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scifionly/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SciFiOnlyApp(),
      ),
    );
    await tester.pump();
    expect(find.text('SciFiOnly'), findsWidgets);

    // Advance past the SplashScreen's 1.5s auto-navigate timer
    // to avoid "Timer is still pending" assertion.
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
