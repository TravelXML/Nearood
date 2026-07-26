import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/join_request.dart';

/// Everything a host needs: creating events, viewing their own events, and
/// managing join requests for them. See supabase/schema.sql for RLS —
/// hosts can only see/manage requests for events they own.
class HostRepository {
  HostRepository._();
  static final HostRepository instance = HostRepository._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<NeighbourlyEvent>> fetchMyEvents() async {
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from('events')
        .select('*, host:profiles!events_host_id_fkey(id, display_name, avatar_url, is_verified)')
        .eq('host_id', userId)
        .order('event_time', ascending: false);
    return (rows as List)
        .map((row) => NeighbourlyEvent.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// Count of pending join requests per event, for badge display on the
  /// host's event list.
  Future<Map<String, int>> fetchPendingRequestCounts(List<String> eventIds) async {
    if (eventIds.isEmpty) return {};
    final rows = await _client
        .from('join_requests')
        .select('event_id')
        .inFilter('event_id', eventIds)
        .eq('status', 'pending');
    final counts = <String, int>{};
    for (final row in rows as List) {
      final id = (row as Map<String, dynamic>)['event_id'] as String;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> createEvent({
    required String title,
    required String category,
    required String description,
    required String location,
    required DateTime eventTime,
    required bool isFree,
    required String priceLabel,
    required int seatsAvailable,
    double? latitude,
    double? longitude,
    String? coverImageUrl,
    List<String> eligibilityTags = const [],
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('events').insert({
      'host_id': userId,
      'title': title,
      'category': category,
      'description': description,
      'location': location,
      'event_time': eventTime.toIso8601String(),
      'is_free': isFree,
      'price_label': priceLabel,
      'seats_available': seatsAvailable,
      'eligibility_tags': eligibilityTags,
      'latitude': ?latitude,
      'longitude': ?longitude,
      'cover_image_url': ?coverImageUrl,
    });
  }

  Future<List<JoinRequestInfo>> fetchRequestsForEvent(String eventId) async {
    final rows = await _client
        .from('join_requests')
        .select('*, requester:profiles!join_requests_requester_id_fkey(display_name, avatar_url, is_verified)')
        .eq('event_id', eventId)
        .order('created_at');
    return (rows as List)
        .map((row) => JoinRequestInfo.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<void> respondToRequest({required String requestId, required String status}) async {
    await _client.from('join_requests').update({'status': status}).eq('id', requestId);
  }
}
