import 'package:flutter/material.dart';
import '../../data/events_repository.dart';
import '../../models/event.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/trust_badge.dart';
import '../explore/explore_screen.dart';

const _categoryLabels = [
  'Weekend Dinner',
  'Tea & Conversation',
  'Senior Assistance',
  'Shopping Help',
  'Local Travel',
  'Walking Group',
  'Games',
  'Cultural Events',
  'Learning and Mentoring',
  'Family Activities',
  'Fitness',
  'Volunteering',
];

/// Home dashboard shell (spec item 6). Category tiles show live event
/// counts pulled from Supabase; other live data feeds (nearby events,
/// requests, etc.) aren't wired up yet in this pass.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, int>> _countsFuture;

  @override
  void initState() {
    super.initState();
    _countsFuture = EventsRepository.instance.fetchCategoryCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.base,
                  AppSpacing.md,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Good morning 👋', style: AppTextStyles.bodyMd),
                              Text(
                                AppSession.instance.neighbourhood ?? 'Set your neighbourhood',
                                style: AppTextStyles.headlineSm,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: Icon(Icons.person_rounded, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base + 4),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search neighbours, events, help...',
                        hintStyle: AppTextStyles.bodyMd,
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base + 4),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.successContainer,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, color: AppColors.success),
                          const SizedBox(width: AppSpacing.base),
                          Expanded(
                            child: Text(
                              'Safety status: All clear. Trusted contacts configured.',
                              style: AppTextStyles.labelMd.copyWith(color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Text('Explore by category', style: AppTextStyles.headlineSm),
                        ),
                        const SizedBox(width: AppSpacing.base),
                        const TrustBadge(
                          label: 'Verified',
                          dense: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.base),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: FutureBuilder<Map<String, int>>(
                future: _countsFuture,
                builder: (context, snapshot) {
                  final counts = snapshot.data ?? const {};
                  return SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: AppSpacing.base,
                      crossAxisSpacing: AppSpacing.base,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _CategoryTile(
                        label: _categoryLabels[i],
                        count: counts[_categoryLabels[i]] ?? 0,
                      ),
                      childCount: _categoryLabels.length,
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('More on the way', style: AppTextStyles.headlineSm),
                      const SizedBox(height: 6),
                      Text(
                        'Nearby activities, weekend dinner invitations, top-rated hosts and suggested neighbours will appear here.',
                        style: AppTextStyles.bodyMd,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyle(label);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ExploreScreen(categoryFilter: label)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      style.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: style.color.withValues(alpha: 0.15),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(style.icon, color: style.color, size: 15),
                      ),
                    ),
                  ],
                ),
              ),
              // Footer band with a solid background so the name/count stay
              // readable regardless of the photo underneath.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: AppColors.surfaceContainerLowest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.onSurface),
                    ),
                    Text(
                      count == 1 ? '1 event' : '$count events',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
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
