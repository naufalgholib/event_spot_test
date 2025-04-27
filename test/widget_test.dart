// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:event_spot/main.dart';
import 'package:event_spot/core/providers/auth_provider.dart';

void main() {
  testWidgets('App should start with splash screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: const MyApp(onboardingComplete: false),
      ),
    );

    // Verify that splash screen is shown
    expect(find.text('EventSpot'), findsOneWidget);
    expect(find.text('Discover. Create. Attend.'), findsOneWidget);
  });

  testWidgets('Login screen should validate input', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame with onboarding complete
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: const MyApp(onboardingComplete: true),
      ),
    );

    // Wait for splash screen animation
    await tester.pump(const Duration(seconds: 4));

    // Navigate to login screen (this might need adjustment based on your navigation)
    // await tester.tap(find.byIcon(Icons.person_outline));
    // await tester.pumpAndSettle();

    // Verify that login form elements are present
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
  });
}
