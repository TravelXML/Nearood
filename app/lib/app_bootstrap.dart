import 'package:flutter/material.dart';
import 'screens/location/select_location_screen.dart';
import 'screens/shell/app_shell.dart';
import 'screens/splash_screen.dart';
import 'state/app_session.dart';
import 'theme/app_colors.dart';

/// Decides the first real screen: Splash (no session — e.g. right after
/// app launch or Google OAuth reload with no session yet), Select Location
/// (signed in but no neighbourhood set), or the app shell. Waits for
/// [AppSession.refresh] so this decision uses up-to-date profile data
/// (important right after an OAuth redirect reload).
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<void> _ready = AppSession.instance.refresh();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final session = AppSession.instance;
        if (!session.isSignedIn) return const SplashScreen();
        if (!session.hasLocation) return const SelectLocationScreen();
        return const AppShell();
      },
    );
  }
}
