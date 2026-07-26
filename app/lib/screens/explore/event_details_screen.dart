import 'package:flutter/material.dart';
import '../../data/events_repository.dart';
import '../../models/event.dart';
import '../../models/review.dart';
import '../../state/app_session.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/trust_badge.dart';
import '../verification/identity_verification_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, required this.event});

  final NeighbourlyEvent event;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  String? _requestStatus;
  bool _loadingStatus = true;
  bool _submitting = false;
  List<EventReview> _reviews = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      EventsRepository.instance.myJoinRequestStatus(widget.event.id),
      EventsRepository.instance.fetchReviews(hostId: widget.event.host.id),
    ]);
    if (!mounted) return;
    setState(() {
      _requestStatus = results[0] as String?;
      _reviews = results[1] as List<EventReview>;
      _loadingStatus = false;
    });
  }

  Future<void> _requestToJoin() async {
    // Only ask for identity verification the first time — once something
    // has been submitted (pending/approved/rejected) we don't re-prompt.
    if (AppSession.instance.verificationStatus == 'none') {
      final submitted = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => IdentityVerificationScreen(
            purpose:
                'Verify your identity to request to join "${widget.event.title}".',
          ),
        ),
      );
      if (submitted != true || !mounted) return;
    }

    setState(() => _submitting = true);
    try {
      await EventsRepository.instance.requestToJoin(widget.event.id);
      if (!mounted) return;
      setState(() {
        _requestStatus = 'pending';
        _submitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request sent to the host of "${widget.event.title}".')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't send the request — try again.")),
      );
    }
  }

  String get _buttonLabel {
    if (_submitting) return 'Sending…';
    return switch (_requestStatus) {
      'pending' => 'Request sent',
      'accepted' => 'Request accepted',
      'rejected' => 'Request declined',
      'cancelled' => 'Request to Join',
      _ => 'Request to Join',
    };
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final host = event.host;
    final style = categoryStyle(event.category);
    final requested = _requestStatus == 'pending' || _requestStatus == 'accepted';

    return Scaffold(
      appBar: AppBar(title: Text(event.category)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              child: event.coverImageUrl != null
                  ? Image.network(
                      event.coverImageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: style.color.withValues(alpha: 0.15),
                        alignment: Alignment.center,
                        child: Icon(style.icon, size: 64, color: style.color),
                      ),
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: style.color.withValues(alpha: 0.15),
                      alignment: Alignment.center,
                      child: Icon(style.icon, size: 64, color: style.color),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(event.title, style: AppTextStyles.displayLgMobile),
            const SizedBox(height: AppSpacing.base),
            _HostCard(host: host),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(icon: Icons.event_rounded, label: _formatDateTime(event.eventTime)),
            _InfoRow(
              icon: Icons.place_outlined,
              label: event.distanceKm != null
                  ? '${event.location} · ${event.distanceKm!.toStringAsFixed(1)} km away'
                  : event.location,
            ),
            _InfoRow(
              icon: Icons.event_seat_rounded,
              label: '${event.seatsAvailable} seats available',
            ),
            _InfoRow(
              icon: Icons.payments_outlined,
              label: event.isFree ? 'Free' : '${event.priceLabel} per person',
            ),
            if (event.eligibilityTags.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.base),
              Text('Who this is for', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
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
            const SizedBox(height: AppSpacing.base),
            Text('About this event', style: AppTextStyles.headlineSm),
            const SizedBox(height: 6),
            Text(event.description, style: AppTextStyles.bodyMd),
            const SizedBox(height: AppSpacing.md),
            if (AppSession.instance.verificationStatus == 'none')
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                margin: const EdgeInsets.only(bottom: AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
                    const SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: Text(
                        "You'll be asked to verify your identity when you request to join.",
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: (_loadingStatus || requested || _submitting) ? null : _requestToJoin,
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_buttonLabel),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              host.reviewCount > 0 ? 'Reviews of ${host.displayName} (${host.reviewCount})' : 'Reviews',
              style: AppTextStyles.headlineSm,
            ),
            const SizedBox(height: AppSpacing.base),
            if (_reviews.isEmpty)
              Text('No reviews yet.', style: AppTextStyles.bodyMd)
            else
              ..._reviews.map((r) => _ReviewTile(review: r)),
          ],
        ),
      ),
    );
  }
}

class _HostCard extends StatelessWidget {
  const _HostCard({required this.host});

  final HostInfo host;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surfaceContainerHigh,
            backgroundImage: host.avatarUrl != null ? NetworkImage(host.avatarUrl!) : null,
            child: host.avatarUrl == null
                ? const Icon(Icons.person_rounded, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Hosted by ${host.displayName}',
                        style: AppTextStyles.labelMd,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (host.avgRating != null) ...[
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.secondaryContainer),
                      const SizedBox(width: 2),
                      Text(
                        '${host.avgRating!.toStringAsFixed(1)} (${host.reviewCount})',
                        style: AppTextStyles.labelSm,
                      ),
                    ] else
                      Text('No ratings yet', style: AppTextStyles.labelSm),
                  ],
                ),
              ],
            ),
          ),
          if (host.isVerified) const TrustBadge(label: 'Verified', dense: true),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final EventReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.surfaceContainerHigh,
                backgroundImage:
                    review.reviewerAvatarUrl != null ? NetworkImage(review.reviewerAvatarUrl!) : null,
                child: review.reviewerAvatarUrl == null
                    ? const Icon(Icons.person_rounded, size: 16, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(child: Text(review.reviewerName, style: AppTextStyles.labelMd)),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14,
                    color: AppColors.secondaryContainer,
                  );
                }),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.comment, style: AppTextStyles.bodyMd),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.base),
          Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
        ],
      ),
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
