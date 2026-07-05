import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:onboarding_app/features/alarm/alarm_provider.dart';
import 'package:onboarding_app/main.dart';

void main() {
  testWidgets('Onboarding app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AlarmProvider())],
        child: const OnboardingApp(),
      ),
    );

    expect(
      find.text('Discover the world, one journey at a time.'),
      findsOneWidget,
    );
  });
}
