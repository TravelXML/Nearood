import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../host/host_screen.dart';
import '../profile/profile_screen.dart';
import '../requests/requests_screen.dart';

/// Bottom-nav shell: Home / Explore / Host / Requests / Profile, plus the
/// floating safety button called out in the spec's main navigation section.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    ExploreScreen(),
    HostScreen(),
    RequestsScreen(),
    ProfileScreen(),
  ];

  static const _destinations = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Explore'),
    (icon: Icons.add_circle_outline_rounded, activeIcon: Icons.add_circle_rounded, label: 'Host'),
    (icon: Icons.inbox_outlined, activeIcon: Icons.inbox_rounded, label: 'Requests'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: _SafetyButton(
        onTap: () => _showSafetySheet(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primaryFixed,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.activeIcon, color: AppColors.primary),
              label: d.label,
            ),
        ],
      ),
    );
  }

  void _showSafetySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Safety Centre', style: AppTextStyles.headlineMd),
              const SizedBox(height: 8),
              Text(
                'SOS, trusted contacts, live check-in and reporting tools live here.',
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.sos_rounded),
                  label: const Text('SOS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafetyButton extends StatelessWidget {
  const _SafetyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: AppColors.error,
      foregroundColor: Colors.white,
      child: const Icon(Icons.shield_rounded),
    );
  }
}
