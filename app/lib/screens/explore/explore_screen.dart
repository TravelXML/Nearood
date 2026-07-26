import 'package:flutter/material.dart';
import '../../data/events_repository.dart';
import '../../models/event.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/trust_badge.dart';
import 'event_details_screen.dart';

/// Explore list of nearby events (spec item 7), backed by the `events`
/// table in Supabase. Map view, filters and masked-host-until-accepted
/// logic aren't wired up yet. Pass [categoryFilter] to show only that
/// category (e.g. tapping a category tile on Home).
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key, this.categoryFilter});

  final String? categoryFilter;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late Future<List<NeighbourlyEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = EventsRepository.instance.fetchUpcomingEvents(category: widget.categoryFilter);
  }

  Future<void> _refresh() async {
    setState(() {
      _eventsFuture = EventsRepository.instance.fetchUpcomingEvents(category: widget.categoryFilter);
    });
    await _eventsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryFilter ?? 'Explore')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<NeighbourlyEvent>>(
            future: _eventsFuture,
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
                    Text('Could not load events', style: AppTextStyles.headlineSm),
                    const SizedBox(height: 6),
                    Text('${snapshot.error}', style: AppTextStyles.bodyMd),
                  ],
                );
              }
              final events = snapshot.data ?? const [];
              if (events.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    const Icon(Icons.event_busy_rounded, size: 40, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: AppSpacing.base),
                    Text('No upcoming events yet', style: AppTextStyles.headlineSm),
                    const SizedBox(height: 6),
                    Text(
                      'Check back soon — new events from your neighbourhood will show up here.',
                      style: AppTextStyles.bodyMd,
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: events.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.base + 4),
                itemBuilder: (context, i) => _EventCard(event: events[i]),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final NeighbourlyEvent event;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyle(event.category);
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event)),
          );
        },
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                child: event.coverImageUrl != null
                    ? Image.network(
                        event.coverImageUrl!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _CategoryFallback(style: style),
                      )
                    : _CategoryFallback(style: style),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.category, style: AppTextStyles.labelSm.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text(event.title, style: AppTextStyles.headlineSm.copyWith(fontSize: 18)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          backgroundImage: event.host.avatarUrl != null
                              ? NetworkImage(event.host.avatarUrl!)
                              : null,
                          child: event.host.avatarUrl == null
                              ? const Icon(Icons.person_rounded, size: 14, color: AppColors.primary)
                              : null,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            event.host.displayName,
                            style: AppTextStyles.labelSm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (event.host.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                        ],
                        if (event.host.avgRating != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.secondaryContainer),
                          const SizedBox(width: 2),
                          Text(event.host.avgRating!.toStringAsFixed(1), style: AppTextStyles.labelSm),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        _formatDateTime(event.eventTime),
                        if (event.distanceKm != null) '${event.distanceKm!.toStringAsFixed(1)} km away'
                        else event.location,
                      ].join(' · '),
                      style: AppTextStyles.labelSm,
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Row(
                      children: [
                        TrustBadge(
                          label: event.isFree ? 'Free' : event.priceLabel,
                          icon: Icons.payments_outlined,
                          dense: true,
                          background: AppColors.surfaceContainerHigh,
                          foreground: AppColors.onSurface,
                        ),
                        const SizedBox(width: AppSpacing.base),
                        Flexible(
                          child: Text(
                            '${event.seatsAvailable} seats left',
                            style: AppTextStyles.labelSm,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (event.eligibilityTags.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.base),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: event.eligibilityTags
                            .map((tag) => TrustBadge(
                                  label: tag,
                                  icon: Icons.groups_rounded,
                                  dense: true,
                                  background: AppColors.primaryFixed,
                                  foreground: AppColors.primary,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryFallback extends StatelessWidget {
  const _CategoryFallback({required this.style});

  final EventCategoryStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      color: style.color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Icon(style.icon, color: style.color, size: 40),
    );
  }
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDateTime(DateTime dt) {
  final local = dt.toLocal();
  final weekday = _weekdays[local.weekday - 1];
  final month = _months[local.month - 1];
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final period = local.hour >= 12 ? 'PM' : 'AM';
  final minute = local.minute.toString().padLeft(2, '0');
  return '$weekday, ${local.day} $month · $hour12:$minute $period';
}
