import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../shell/app_shell.dart';

/// Shown right after sign-in if the user hasn't set a location yet.
/// Needed so Explore can show "near me" distances against real events.
class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  final _searchController = TextEditingController();
  List<GeoPoint> _results = [];
  bool _searching = false;
  bool _usingCurrent = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _usingCurrent = true;
      _error = null;
    });
    try {
      final point = await LocationService.instance.useCurrentLocation();
      await _save(point);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _usingCurrent = false;
        _error = 'Could not get your location: $e';
      });
    }
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    final results = await LocationService.instance.search(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  Future<void> _save(GeoPoint point) async {
    await AppSession.instance.saveLocation(
      latitude: point.latitude,
      longitude: point.longitude,
      neighbourhood: point.label,
    );
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.base),
              const Icon(Icons.location_on_rounded, size: 44, color: AppColors.primary),
              const SizedBox(height: AppSpacing.base),
              Text("Where's your neighbourhood?", style: AppTextStyles.displayLgMobile),
              const SizedBox(height: AppSpacing.base),
              Text(
                "We'll use this to show nearby events and how far away they are. You can change it anytime.",
                style: AppTextStyles.bodyMd,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: _usingCurrent ? null : _useCurrentLocation,
                icon: _usingCurrent
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.my_location_rounded, size: 20),
                label: Text(_usingCurrent ? 'Locating…' : 'Use my current location'),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.base),
                Text(_error!, style: AppTextStyles.labelMd.copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('or search', style: AppTextStyles.labelSm),
                  ),
                  const Expanded(child: Divider(color: AppColors.outlineVariant)),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search area, city or pincode',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onSubmitted: _search,
              ),
              const SizedBox(height: AppSpacing.base),
              if (_searching) const Center(child: CircularProgressIndicator()),
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, i) {
                    final r = _results[i];
                    return ListTile(
                      leading: const Icon(Icons.place_outlined, color: AppColors.primary),
                      title: Text(r.label, style: AppTextStyles.bodyMd, maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () => _save(r),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
