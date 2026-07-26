#!/usr/bin/env bash
# Seeds realistic demo data: host/reviewer accounts, events (with location +
# cover image), and reviews. Uses the service_role key, which bypasses RLS —
# never ship this key in the app, it's for one-off admin seeding only.
#
# Usage:
#   PROJECT_URL="https://xxxx.supabase.co" SERVICE_ROLE_KEY="..." ./seed_demo_data.sh
set -euo pipefail

: "${PROJECT_URL:?Set PROJECT_URL}"
: "${SERVICE_ROLE_KEY:?Set SERVICE_ROLE_KEY}"

AUTH_HEADERS=(-H "apikey: $SERVICE_ROLE_KEY" -H "Authorization: Bearer $SERVICE_ROLE_KEY" -H "Content-Type: application/json")
REST_HEADERS=("${AUTH_HEADERS[@]}" -H "Prefer: return=representation")

# Base coordinate: Connaught Place, New Delhi. Everything else is offset
# from here by small lat/lng deltas to simulate a real neighbourhood.
BASE_LAT=28.6315
BASE_LON=77.2167

create_user() {
  local email="$1" name="$2"
  curl -s -X POST "$PROJECT_URL/auth/v1/admin/users" "${AUTH_HEADERS[@]}" -d "$(jq -n \
    --arg email "$email" --arg name "$name" \
    '{email:$email, password:("Demo-"+($name|ascii_downcase|gsub(" ";""))+"-2026!"), email_confirm:true, user_metadata:{display_name:$name}}')" \
    | jq -r '.id'
}

update_profile() {
  local id="$1" avatar="$2" verified="$3" hood="$4" lat="$5" lon="$6"
  curl -s -X PATCH "$PROJECT_URL/rest/v1/profiles?id=eq.$id" "${REST_HEADERS[@]}" -d "$(jq -n \
    --arg avatar "$avatar" --argjson verified "$verified" --arg hood "$hood" --argjson lat "$lat" --argjson lon "$lon" \
    '{avatar_url:$avatar, is_verified:$verified, neighbourhood:$hood, latitude:$lat, longitude:$lon}')" > /dev/null
}

echo "Creating demo hosts..."
PRIYA=$(create_user "priya.demo@neighbourly.test" "Priya Sharma")
ROHAN=$(create_user "rohan.demo@neighbourly.test" "Rohan Mehta")
ANJALI=$(create_user "anjali.demo@neighbourly.test" "Anjali Iyer")
KARAN=$(create_user "karan.demo@neighbourly.test" "Karan Verma")
SUNITA=$(create_user "sunita.demo@neighbourly.test" "Sunita Rao")
echo "  priya=$PRIYA rohan=$ROHAN anjali=$ANJALI karan=$KARAN sunita=$SUNITA"

update_profile "$PRIYA"  "https://i.pravatar.cc/150?img=47" true  "Green Park, Delhi"      28.6280 77.2065
update_profile "$ROHAN"  "https://i.pravatar.cc/150?img=12" true  "Sector 12, Noida"       28.5820 77.3160
update_profile "$ANJALI" "https://i.pravatar.cc/150?img=32" true  "Old Town, Lucknow"      28.6480 77.2190
update_profile "$KARAN"  "https://i.pravatar.cc/150?img=51" false "Lodhi Colony, Delhi"    28.5890 77.2260
update_profile "$SUNITA" "https://i.pravatar.cc/150?img=44" true  "Vasant Vihar, Delhi"    28.5590 77.1590

create_event() {
  local host="$1" title="$2" category="$3" desc="$4" loc="$5" days_from_now="$6" \
        is_free="$7" price="$8" seats="$9" lat="${10}" lon="${11}" img="${12}"
  local event_time
  event_time=$(python3 -c "import datetime; print((datetime.datetime.utcnow()+datetime.timedelta(days=$days_from_now, hours=3)).isoformat()+'Z')")
  curl -s -X POST "$PROJECT_URL/rest/v1/events" "${REST_HEADERS[@]}" -d "$(jq -n \
    --arg host "$host" --arg title "$title" --arg category "$category" --arg desc "$desc" \
    --arg loc "$loc" --arg time "$event_time" --argjson is_free "$is_free" --arg price "$price" \
    --argjson seats "$seats" --argjson lat "$lat" --argjson lon "$lon" --arg img "$img" \
    '{host_id:$host, title:$title, category:$category, description:$desc, location:$loc,
      event_time:$time, is_free:$is_free, price_label:$price, seats_available:$seats,
      latitude:$lat, longitude:$lon, cover_image_url:$img}')" | jq -r '.[0].id'
}

echo "Creating demo events..."
E1=$(create_event "$PRIYA" "Sunday Home-Cooked Dinner" "Weekend Dinner" \
  "A home-style vegetarian dinner for neighbours who want to share a meal and get to know each other. Bring your appetite and a story to tell." \
  "Green Park, Delhi" 4 false '₹300' 4 28.6280 77.2065 "https://picsum.photos/id/292/800/600")

E2=$(create_event "$ROHAN" "Evening Tea with Senior Neighbours" "Tea & Conversation" \
  "A relaxed evening of tea, biscuits and conversation for senior residents in the neighbourhood. Family and helpers welcome to accompany." \
  "Sector 12, Noida" 3 true 'Free' 8 28.5820 77.3160 "https://picsum.photos/id/225/800/600")

E3=$(create_event "$ANJALI" "Weekend Heritage Walk" "Cultural Events" \
  "A guided morning walk through the old town covering local history, architecture and a shared breakfast stop along the way." \
  "Old Town, Lucknow" 5 false '₹150' 12 28.6480 77.2190 "https://picsum.photos/id/1015/800/600")

E4=$(create_event "$KARAN" "Saturday Morning Walking Group" "Walking Group" \
  "A brisk 5km walk around the neighbourhood park, followed by fresh coconut water. All fitness levels welcome." \
  "Lodhi Colony, Delhi" 2 true 'Free' 15 28.5890 77.2260 "https://picsum.photos/id/1043/800/600")

E5=$(create_event "$SUNITA" "Grocery Shopping Support" "Shopping Help" \
  "Offering to accompany elderly or mobility-limited neighbours on their weekly grocery run. Just need a day's notice." \
  "Vasant Vihar, Delhi" 1 true 'Free' 3 28.5590 77.1590 "https://picsum.photos/id/102/800/600")

E6=$(create_event "$PRIYA" "Board Games Evening" "Games" \
  "Settlers of Catan, Uno, and chess. Snacks provided, just bring your competitive spirit." \
  "Green Park, Delhi" 6 false '₹100' 6 28.6295 77.2080 "https://picsum.photos/id/119/800/600")

E7=$(create_event "$ANJALI" "Beginner Watercolour Workshop" "Learning and Mentoring" \
  "A relaxed 2-hour watercolour session for beginners — materials provided, no experience needed." \
  "Old Town, Lucknow" 7 false '₹250' 8 28.6470 77.2175 "https://picsum.photos/id/1025/800/600")

E8=$(create_event "$SUNITA" "Community Park Cleanup" "Volunteering" \
  "Join fellow residents for a Sunday morning cleanup of the neighbourhood park. Gloves and bags provided." \
  "Vasant Vihar, Delhi" 9 true 'Free' 20 28.5605 77.1605 "https://picsum.photos/id/1039/800/600")

echo "  events: $E1 $E2 $E3 $E4 $E5 $E6 $E7 $E8"

add_review() {
  local event="$1" host="$2" reviewer="$3" rating="$4" comment="$5"
  curl -s -X POST "$PROJECT_URL/rest/v1/reviews" "${REST_HEADERS[@]}" -d "$(jq -n \
    --arg event "$event" --arg host "$host" --arg reviewer "$reviewer" --argjson rating "$rating" --arg comment "$comment" \
    '{event_id:$event, host_id:$host, reviewer_id:$reviewer, rating:$rating, comment:$comment}')" > /dev/null
}

echo "Adding demo reviews..."
add_review "$E1" "$PRIYA" "$ROHAN"  5 "Wonderful evening, Priya is a fantastic host and the food was amazing!"
add_review "$E1" "$PRIYA" "$ANJALI" 5 "Felt so welcomed, met great neighbours. Highly recommend."
add_review "$E1" "$PRIYA" "$KARAN"  4 "Great vibe, ran a little long but worth it."
add_review "$E2" "$ROHAN" "$SUNITA" 5 "My mother had a lovely time, Rohan was so patient and kind."
add_review "$E2" "$ROHAN" "$PRIYA"  5 "Very well organised, seniors felt genuinely cared for."
add_review "$E3" "$ANJALI" "$KARAN" 5 "Anjali knows so much local history, loved the walk."
add_review "$E5" "$SUNITA" "$ROHAN" 5 "Sunita helped my grandfather with groceries, very reliable and punctual."
add_review "$E8" "$SUNITA" "$PRIYA" 4 "Good turnout, well coordinated cleanup."

echo "Done."
