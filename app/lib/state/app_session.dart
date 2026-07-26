import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps Supabase auth state + the signed-in user's profile/verification
/// status. Refreshes automatically whenever Supabase's auth state changes
/// (sign in, sign out, token refresh).
class AppSession extends ChangeNotifier {
  AppSession._() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) => refresh());
    refresh();
  }
  static final AppSession instance = AppSession._();

  SupabaseClient get _client => Supabase.instance.client;

  bool isSignedIn = false;
  bool isVerified = false;

  /// 'none' | 'pending' | 'approved' | 'rejected'
  String verificationStatus = 'none';
  String? displayName;

  double? latitude;
  double? longitude;
  String? neighbourhood;

  bool get hasLocation => latitude != null && longitude != null;

  Future<void> refresh() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      isSignedIn = false;
      isVerified = false;
      verificationStatus = 'none';
      displayName = null;
      latitude = null;
      longitude = null;
      neighbourhood = null;
      notifyListeners();
      return;
    }

    isSignedIn = true;

    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    displayName = (profile?['display_name'] as String?) ?? user.email;
    isVerified = profile?['is_verified'] as bool? ?? false;
    latitude = (profile?['latitude'] as num?)?.toDouble();
    longitude = (profile?['longitude'] as num?)?.toDouble();
    neighbourhood = profile?['neighbourhood'] as String?;

    final verification = await _client
        .from('verification_requests')
        .select('status')
        .eq('user_id', user.id)
        .order('submitted_at', ascending: false)
        .limit(1)
        .maybeSingle();
    verificationStatus = verification?['status'] as String? ?? 'none';

    notifyListeners();
  }

  Future<void> saveLocation({
    required double latitude,
    required double longitude,
    required String neighbourhood,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('profiles').update({
      'latitude': latitude,
      'longitude': longitude,
      'neighbourhood': neighbourhood,
    }).eq('id', userId);
    this.latitude = latitude;
    this.longitude = longitude;
    this.neighbourhood = neighbourhood;
    notifyListeners();
  }

  Future<void> signOut() => _client.auth.signOut();
}
