import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/review.dart';
import '../services/location_service.dart';
import '../state/app_session.dart';

/// Thin wrapper around the `events` / `join_requests` / `reviews` tables
/// (see supabase/schema.sql + migrations at the repo root for the exact
/// schema + RLS).
class EventsRepository {
  EventsRepository._();
  static final EventsRepository instance = EventsRepository._();

  SupabaseClient get _client => Supabase.instance.client;

  /// Upcoming events with host info + rating, sorted by distance from the
  /// signed-in user's saved location (closest first) when available,
  /// otherwise by start time. Pass [category] to only fetch that category.
  Future<List<NeighbourlyEvent>> fetchUpcomingEvents({String? category}) async {
    var query = _client
        .from('events')
        .select('*, host:profiles!events_host_id_fkey(id, display_name, avatar_url, is_verified)')
        .gte('event_time', DateTime.now().toIso8601String());
    if (category != null) {
      query = query.eq('category', category);
    }
    final rows = await query.order('event_time');

    final events = (rows as List)
        .map((row) => NeighbourlyEvent.fromMap(row as Map<String, dynamic>))
        .toList();

    await _attachRatings(events);
    _attachDistances(events);

    final userLat = AppSession.instance.latitude;
    if (userLat != null) {
      events.sort((a, b) => (a.distanceKm ?? double.infinity).compareTo(b.distanceKm ?? double.infinity));
    }
    return events;
  }

  /// Count of upcoming events per category. Tallied client-side since this
  /// project's PostgREST has aggregate functions disabled (the sane
  /// default) — fine at this data volume.
  Future<Map<String, int>> fetchCategoryCounts() async {
    final rows = await _client
        .from('events')
        .select('category')
        .gte('event_time', DateTime.now().toIso8601String());
    final counts = <String, int>{};
    for (final row in rows as List) {
      final category = (row as Map<String, dynamic>)['category'] as String;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _attachRatings(List<NeighbourlyEvent> events) async {
    if (events.isEmpty) return;
    final hostIds = events.map((e) => e.host.id).toSet().toList();
    final ratings = await _client
        .from('host_ratings')
        .select()
        .inFilter('host_id', hostIds);
    final byHost = {
      for (final r in ratings as List) (r as Map<String, dynamic>)['host_id'] as String: r,
    };
    for (var i = 0; i < events.length; i++) {
      final rating = byHost[events[i].host.id];
      if (rating == null) continue;
      final rated = events[i].host.withRating(
        avgRating: (rating['avg_rating'] as num?)?.toDouble(),
        reviewCount: rating['review_count'] as int? ?? 0,
      );
      events[i] = NeighbourlyEvent(
        id: events[i].id,
        host: rated,
        title: events[i].title,
        category: events[i].category,
        description: events[i].description,
        location: events[i].location,
        eventTime: events[i].eventTime,
        isFree: events[i].isFree,
        priceLabel: events[i].priceLabel,
        seatsAvailable: events[i].seatsAvailable,
        latitude: events[i].latitude,
        longitude: events[i].longitude,
        coverImageUrl: events[i].coverImageUrl,
        eligibilityTags: events[i].eligibilityTags,
      );
    }
  }

  void _attachDistances(List<NeighbourlyEvent> events) {
    final userLat = AppSession.instance.latitude;
    final userLon = AppSession.instance.longitude;
    if (userLat == null || userLon == null) return;
    for (final event in events) {
      if (event.latitude == null || event.longitude == null) continue;
      event.distanceKm = LocationService.instance.distanceKm(
        userLat,
        userLon,
        event.latitude!,
        event.longitude!,
      );
    }
  }

  Future<List<EventReview>> fetchReviews({required String hostId}) async {
    final rows = await _client
        .from('reviews')
        .select('*, reviewer:profiles!reviews_reviewer_id_fkey(display_name, avatar_url)')
        .eq('host_id', hostId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => EventReview.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Returns the signed-in user's request status for [eventId], or null if
  /// they haven't requested to join.
  Future<String?> myJoinRequestStatus(String eventId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('join_requests')
        .select('status')
        .eq('event_id', eventId)
        .eq('requester_id', userId)
        .maybeSingle();
    return row?['status'] as String?;
  }

  Future<void> requestToJoin(String eventId) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('join_requests').insert({
      'event_id': eventId,
      'requester_id': userId,
    });
  }
}
