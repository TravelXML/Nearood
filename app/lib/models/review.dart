class EventReview {
  const EventReview({
    required this.id,
    required this.rating,
    required this.comment,
    required this.reviewerName,
    required this.reviewerAvatarUrl,
    required this.createdAt,
  });

  final String id;
  final int rating;
  final String comment;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final DateTime createdAt;

  factory EventReview.fromMap(Map<String, dynamic> map) {
    final reviewer = map['reviewer'] as Map<String, dynamic>?;
    return EventReview(
      id: map['id'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String? ?? '',
      reviewerName: (reviewer?['display_name'] as String?) ?? 'A neighbour',
      reviewerAvatarUrl: reviewer?['avatar_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
