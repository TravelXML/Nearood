#!/usr/bin/env bash
# Runs the app with Supabase credentials from .env.local (copy
# .env.local.example and fill in your project's URL + anon key).
set -euo pipefail
cd "$(dirname "$0")/.."

ENV_FILE=".env.local"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE. Copy .env.local.example to .env.local and fill in your Supabase project's URL and anon key." >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "$ENV_FILE"
set +a

exec flutter run \
  --dart-define=SUPABASE_URL="${SUPABASE_URL:?SUPABASE_URL not set in .env.local}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY not set in .env.local}" \
  "$@"
