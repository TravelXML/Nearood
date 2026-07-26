/// Supabase project credentials, supplied at build/run time via
/// --dart-define (see scripts/run.sh at the repo root). The anon key is
/// Supabase's public client key — safe to ship in a client app, it's not
/// a secret, access is enforced by Row Level Security policies instead.
class SupabaseConfig {
  SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
