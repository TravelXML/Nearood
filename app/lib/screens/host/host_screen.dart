import 'package:flutter/material.dart';
import '../../data/host_repository.dart';
import '../../models/event.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import 'create_event_screen.dart';
import 'manage_requests_screen.dart';

/// Host dashboard: the events you're hosting, with a shortcut into request
/// management for each, plus the entry point to create a new one.
class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  late Future<_HostData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _dataFuture = _fetchData();
  }

  Future<_HostData> _fetchData() async {
    final events = await HostRepository.instance.fetchMyEvents();
    final counts = await HostRepository.instance.fetchPendingRequestCounts(
      events.map((e) => e.id).toList(),
    );
    return _HostData(events, counts);
  }

  Future<void> _createEvent() async {
    final published = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateEventScreen()),
    );
    if (published == true && mounted) {
      setState(_load);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event published!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Host')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createEvent,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Event'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(_load);
            await _dataFuture;
          },
          child: FutureBuilder<_HostData>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.base),
                    Text('Could not load your events', style: AppTextStyles.headlineSm),
                    const SizedBox(height: 6),
                    Text('${snapshot.error}', style: AppTextStyles.bodyMd),
                  ],
                );
              }
              final events = snapshot.data?.events ?? const [];
              final counts = snapshot.data?.pendingCounts ?? const {};
              if (events.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    const Icon(Icons.celebration_rounded, size: 40, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.base),
                    Text("You're not hosting anything yet", style: AppTextStyles.headlineSm),
                    const SizedBox(height: 6),
                    Text(
                      'Weekend dinners, walking groups, senior assistance — create your first event and neighbours nearby will see it in Explore.',
                      style: AppTextStyles.bodyMd,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: _createEvent,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('Create your first event'),
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 88),
                itemCount: events.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.base),
                itemBuilder: (context, i) => _HostedEventCard(
                  event: events[i],
                  pendingCount: counts[events[i].id] ?? 0,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ManageRequestsScreen(event: events[i])),
                    );
                    if (mounted) setState(_load);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HostData {
  const _HostData(this.events, this.pendingCounts);
  final List<NeighbourlyEvent> events;
  final Map<String, int> pendingCounts;
}

class _HostedEventCard extends StatelessWidget {
  const _HostedEventCard({required this.event, required this.pendingCount, required this.onTap});

  final NeighbourlyEvent event;
  final int pendingCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyle(event.category);
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(style.icon, color: style.color, size: 26),
              ),
              const SizedBox(width: AppSpacing.base + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.category, style: AppTextStyles.labelSm.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text(event.title, style: AppTextStyles.headlineSm.copyWith(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text('${event.seatsAvailable} seats · ${event.isFree ? 'Free' : event.priceLabel}',
                        style: AppTextStyles.labelSm),
                  ],
                ),
              ),
              if (pendingCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '$pendingCount new',
                    style: AppTextStyles.labelSm.copyWith(color: Colors.white),
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );
  }
}
