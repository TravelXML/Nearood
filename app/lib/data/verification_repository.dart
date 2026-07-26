import 'package:supabase_flutter/supabase_flutter.dart';

/// Stores self-declared Aadhaar/govt-ID verification submissions for human
/// review. This does NOT validate anything against UIDAI or any government
/// system — real eKYC needs a licensed provider integration. See
/// supabase/schema.sql for the `verification_requests` table.
class VerificationRepository {
  VerificationRepository._();
  static final VerificationRepository instance = VerificationRepository._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> submitAadhaarVerification({required String last4}) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('verification_requests').insert({
      'user_id': userId,
      'method': 'aadhaar',
      'id_last4': last4,
    });
  }

  /// Status of the most recent submission: 'pending' | 'approved' |
  /// 'rejected', or null if nothing has been submitted yet.
  Future<String?> latestStatus() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    final row = await _client
        .from('verification_requests')
        .select('status')
        .eq('user_id', userId)
        .order('submitted_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row?['status'] as String?;
  }
}
