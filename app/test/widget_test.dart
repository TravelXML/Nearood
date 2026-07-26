import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neighbourly/screens/splash_screen.dart';
import 'package:neighbourly/screens/welcome_screen.dart';
import 'package:neighbourly/theme/app_theme.dart';

// These tests deliberately pump individual screens (not NeighbourlyApp)
// so they don't need a live Supabase connection: main.dart's entry point
// now depends on Supabase being initialized, and screens past Welcome
// (Sign In, Explore, Profile, ...) talk to a real backend. Testing those
// would need a mocked Supabase client — out of scope for this pass.
void main() {
  testWidgets('Splash screen auto-advances to Welcome', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
    );

    expect(find.text('Trusted people.\nMeaningful moments. Nearby.'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(milliseconds: 1700));

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Join the Neighborhood'), findsOneWidget);
  });
}
