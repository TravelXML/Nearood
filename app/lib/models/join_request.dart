class JoinRequestInfo {
  const JoinRequestInfo({
    required this.id,
    required this.status,
    required this.requesterId,
    required this.requesterName,
    required this.requesterAvatarUrl,
    required this.requesterVerified,
    required this.createdAt,
  });

  final String id;
  final String status;
  final String requesterId;
  final String requesterName;
  final String? requesterAvatarUrl;
  final bool requesterVerified;
  final DateTime createdAt;

  factory JoinRequestInfo.fromMap(Map<String, dynamic> map) {
    final requester = map['requester'] as Map<String, dynamic>?;
    return JoinRequestInfo(
      id: map['id'] as String,
      status: map['status'] as String,
      requesterId: map['requester_id'] as String,
      requesterName: (requester?['display_name'] as String?) ?? 'A neighbour',
      requesterAvatarUrl: requester?['avatar_url'] as String?,
      requesterVerified: requester?['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
