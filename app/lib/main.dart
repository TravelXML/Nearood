import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_bootstrap.dart';
import 'config/supabase_config.dart';
import 'screens/setup_required_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }
  runApp(const NeighbourlyApp());
}

class NeighbourlyApp extends StatelessWidget {
  const NeighbourlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neighbourly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // This is a mobile-first design. On wide (desktop web) viewports,
      // letterbox it to a phone-width column instead of stretching every
      // layout — matches how the Stitch mockups were designed.
      builder: (context, child) {
        return ColoredBox(
          color: AppColors.surfaceContainerHigh,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        );
      },
      home: SupabaseConfig.isConfigured ? const AppBootstrap() : const SetupRequiredScreen(),
    );
  }
}
