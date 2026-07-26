import 'package:flutter/material.dart';
import '../../data/host_repository.dart';
import '../../models/event.dart';
import '../../models/join_request.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/trust_badge.dart';

/// Host request management (spec item 9), scoped to one event: accept or
/// reject the people who've asked to join.
class ManageRequestsScreen extends StatefulWidget {
  const ManageRequestsScreen({super.key, required this.event});

  final NeighbourlyEvent event;

  @override
  State<ManageRequestsScreen> createState() => _ManageRequestsScreenState();
}

class _ManageRequestsScreenState extends State<ManageRequestsScreen> {
  late Future<List<JoinRequestInfo>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _requestsFuture = HostRepository.instance.fetchRequestsForEvent(widget.event.id);
  }

  Future<void> _respond(JoinRequestInfo request, String status) async {
    try {
      await HostRepository.instance.respondToRequest(requestId: request.id, status: status);
      if (!mounted) return;
      setState(_load);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${request.requesterName} ${status == 'accepted' ? 'accepted' : 'declined'}.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't update the request — try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event.title)),
      body: SafeArea(
        child: FutureBuilder<List<JoinRequestInfo>>(
          future: _requestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final requests = snapshot.data ?? const [];
            if (requests.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  const Icon(Icons.inbox_outlined, size: 40, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.base),
                  Text('No requests yet', style: AppTextStyles.headlineSm),
                  const SizedBox(height: 6),
                  Text(
                    "You'll see people here once they request to join this event.",
                    style: AppTextStyles.bodyMd,
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: requests.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.base),
              itemBuilder: (context, i) => _RequestCard(
                request: requests[i],
                onAccept: () => _respond(requests[i], 'accepted'),
                onReject: () => _respond(requests[i], 'rejected'),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onAccept, required this.onReject});

  final JoinRequestInfo request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceContainerHigh,
                backgroundImage:
                    request.requesterAvatarUrl != null ? NetworkImage(request.requesterAvatarUrl!) : null,
                child: request.requesterAvatarUrl == null
                    ? const Icon(Icons.person_rounded, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.requesterName, style: AppTextStyles.labelMd),
                    Text(_statusLabel(request.status), style: AppTextStyles.labelSm),
                  ],
                ),
              ),
              if (request.requesterVerified) const TrustBadge(label: 'Verified', dense: true),
            ],
          ),
          if (request.status == 'pending') ...[
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error, width: 2),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'accepted' => 'Accepted',
        'rejected' => 'Declined',
        'cancelled' => 'Cancelled',
        _ => 'Pending your response',
      };
}
