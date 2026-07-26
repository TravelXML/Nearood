import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HostInfo {
  const HostInfo({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.avgRating,
    this.reviewCount = 0,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final double? avgRating;
  final int reviewCount;

  factory HostInfo.fromMap(Map<String, dynamic> map) {
    return HostInfo(
      id: map['id'] as String,
      displayName: (map['display_name'] as String?)?.trim().isNotEmpty == true
          ? map['display_name'] as String
          : 'A neighbour',
      avatarUrl: map['avatar_url'] as String?,
      isVerified: map['is_verified'] as bool? ?? false,
    );
  }

  HostInfo withRating({double? avgRating, int reviewCount = 0}) {
    return HostInfo(
      id: id,
      displayName: displayName,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      avgRating: avgRating,
      reviewCount: reviewCount,
    );
  }
}

class NeighbourlyEvent {
  NeighbourlyEvent({
    required this.id,
    required this.host,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.eventTime,
    required this.isFree,
    required this.priceLabel,
    required this.seatsAvailable,
    this.latitude,
    this.longitude,
    this.coverImageUrl,
    this.eligibilityTags = const [],
    this.distanceKm,
  });

  final String id;
  final HostInfo host;
  final String title;
  final String category;
  final String description;
  final String location;
  final DateTime eventTime;
  final bool isFree;
  final String priceLabel;
  final int seatsAvailable;
  final double? latitude;
  final double? longitude;
  final String? coverImageUrl;
  final List<String> eligibilityTags;

  /// Distance from the viewer, filled in client-side once we know their
  /// location — not a property of the event itself.
  double? distanceKm;

  factory NeighbourlyEvent.fromMap(Map<String, dynamic> map) {
    final hostMap = map['host'] as Map<String, dynamic>?;
    return NeighbourlyEvent(
      id: map['id'] as String,
      host: hostMap != null
          ? HostInfo.fromMap(hostMap)
          : HostInfo(id: map['host_id'] as String, displayName: 'A neighbour'),
      title: map['title'] as String,
      category: map['category'] as String,
      description: map['description'] as String? ?? '',
      location: map['location'] as String? ?? '',
      eventTime: DateTime.parse(map['event_time'] as String),
      isFree: map['is_free'] as bool? ?? true,
      priceLabel: map['price_label'] as String? ?? 'Free',
      seatsAvailable: map['seats_available'] as int? ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      coverImageUrl: map['cover_image_url'] as String?,
      eligibilityTags: (map['eligibility_tags'] as List?)?.cast<String>() ?? const [],
    );
  }
}

class EventCategoryStyle {
  const EventCategoryStyle(this.icon, this.color, this.imageUrl);
  final IconData icon;
  final Color color;
  final String imageUrl;
}

const _categoryStyles = <String, EventCategoryStyle>{
  'Weekend Dinner': EventCategoryStyle(
      Icons.dinner_dining_rounded, AppColors.secondaryContainer, 'https://picsum.photos/id/292/400/400'),
  'Tea & Conversation': EventCategoryStyle(
      Icons.emoji_food_beverage_rounded, AppColors.tertiaryContainer, 'https://picsum.photos/id/225/400/400'),
  'Senior Assistance': EventCategoryStyle(
      Icons.elderly_rounded, AppColors.primary, 'https://picsum.photos/id/1027/400/400'),
  'Shopping Help': EventCategoryStyle(
      Icons.local_grocery_store_rounded, AppColors.secondaryContainer, 'https://picsum.photos/id/1080/400/400'),
  'Local Travel': EventCategoryStyle(
      Icons.directions_car_filled_rounded, AppColors.tertiaryContainer, 'https://picsum.photos/id/1051/400/400'),
  'Walking Group': EventCategoryStyle(
      Icons.directions_walk_rounded, AppColors.primary, 'https://picsum.photos/id/1043/400/400'),
  'Games': EventCategoryStyle(
      Icons.casino_rounded, AppColors.secondaryContainer, 'https://picsum.photos/id/119/400/400'),
  'Cultural Events': EventCategoryStyle(
      Icons.festival_rounded, AppColors.tertiaryContainer, 'https://picsum.photos/id/1015/400/400'),
  'Learning and Mentoring': EventCategoryStyle(
      Icons.school_rounded, AppColors.primary, 'https://picsum.photos/id/1025/400/400'),
  'Family Activities': EventCategoryStyle(
      Icons.family_restroom_rounded, AppColors.secondaryContainer, 'https://picsum.photos/id/1062/400/400'),
  'Fitness': EventCategoryStyle(
      Icons.fitness_center_rounded, AppColors.tertiaryContainer, 'https://picsum.photos/id/1074/400/400'),
  'Volunteering': EventCategoryStyle(
      Icons.volunteer_activism_rounded, AppColors.primary, 'https://picsum.photos/id/1039/400/400'),
};

EventCategoryStyle categoryStyle(String category) =>
    _categoryStyles[category] ??
    const EventCategoryStyle(Icons.event_rounded, AppColors.primary, 'https://picsum.photos/id/1084/400/400');
