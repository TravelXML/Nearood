#!/usr/bin/env python3
"""Seeds ~100 events across all 12 categories, based in Whitefield,
Bangalore, with 8 new local hosts. Uses the service_role key (bypasses
RLS) — never ship that key in the app, this is one-off admin seeding.

Usage:
  PROJECT_URL="https://xxxx.supabase.co" SERVICE_ROLE_KEY="..." python3 seed_whitefield_100.py
"""
import json
import os
import random
import urllib.request
from datetime import datetime, timedelta, timezone

PROJECT_URL = os.environ["PROJECT_URL"]
SERVICE_ROLE_KEY = os.environ["SERVICE_ROLE_KEY"]

random.seed(42)

# Whitefield, Bangalore approximate centre.
BASE_LAT, BASE_LON = 12.9698, 77.7500


def jitter(base, spread=0.025):
    return round(base + random.uniform(-spread, spread), 6)


def api(method, path, body=None):
    url = f"{PROJECT_URL}{path}"
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("apikey", SERVICE_ROLE_KEY)
    req.add_header("Authorization", f"Bearer {SERVICE_ROLE_KEY}")
    req.add_header("Content-Type", "application/json")
    req.add_header("Prefer", "return=representation")
    with urllib.request.urlopen(req) as resp:
        raw = resp.read()
        return json.loads(raw) if raw else None


HOSTS = [
    ("deepa.demo@neighbourly.test", "Deepa Nair", 5, True),
    ("arjun.demo@neighbourly.test", "Arjun Reddy", 8, True),
    ("meera.demo@neighbourly.test", "Meera Krishnan", 15, True),
    ("vikram.demo@neighbourly.test", "Vikram Rao", 20, False),
    ("lakshmi.demo@neighbourly.test", "Lakshmi Iyengar", 25, True),
    ("suresh.demo@neighbourly.test", "Suresh Kumar", 33, True),
    ("ananya.demo@neighbourly.test", "Ananya Bhat", 40, True),
    ("rahul.demo@neighbourly.test", "Rahul Gowda", 60, False),
]

SUBLOCALITIES = [
    "ITPL Main Road, Whitefield", "Hope Farm Junction, Whitefield",
    "Kadugodi, Whitefield", "Varthur Road, Whitefield",
    "Brookefield, Whitefield", "Hoodi Circle, Whitefield",
    "Channasandra, Whitefield", "Vydehi, Whitefield",
]

CATEGORIES = {
    "Weekend Dinner": [
        "Sunday Home-Cooked Dinner", "Friday Night Potluck", "South Indian Thali Night",
        "Rooftop BBQ Dinner", "Vegan Dinner Club", "Sunday Brunch & Dinner Combo",
        "Neighbourhood Biryani Night", "Home Kitchen Supper Club", "Continental Dinner Evening",
        "Wine & Cheese Dinner Night",
    ],
    "Tea & Conversation": [
        "Evening Tea with Senior Neighbours", "Chai & Chat Circle", "Morning Coffee Meetup",
        "Tea Time Book Talk", "Sunset Tea Gathering", "Ladies' Tea Circle",
        "Retiree Tea Meetup", "Weekend Filter Coffee Adda",
    ],
    "Senior Assistance": [
        "Companion Visit for Seniors", "Senior Tech Help Session", "Doctor Visit Accompaniment",
        "Senior Citizens' Morning Walk", "Pension Paperwork Help", "Senior Wellness Check-in",
        "Reading Companion for Seniors", "Senior Citizens' Card Games",
    ],
    "Shopping Help": [
        "Grocery Shopping Support", "Weekly Market Run Assistance", "Pharmacy Pickup Help",
        "Festive Shopping Companion", "Big Bazaar Run Together", "Online Order Pickup Help",
        "Vegetable Market Assistance", "Monthly Ration Shopping Help",
    ],
    "Local Travel": [
        "Airport Drop Assistance", "Metro Station Companion Ride", "Local Travel Buddy",
        "Railway Station Pickup Help", "Cab Share to ITPL", "Hospital Visit Travel Support",
        "Evening Commute Buddy", "Weekend Outstation Trip Share",
    ],
    "Walking Group": [
        "Saturday Morning Walking Group", "Evening Park Walk", "Whitefield Lake Walk",
        "Brisk Walkers Club", "Sunrise Walking Group", "Senior-Friendly Walking Group",
        "Weekend Nature Trail Walk", "Post-Dinner Stroll Group",
    ],
    "Games": [
        "Board Games Evening", "Chess Club Meetup", "Carrom Tournament Night",
        "Card Games Get-together", "Family Games Night", "Uno & Monopoly Evening",
        "Weekend Quiz Night", "Table Tennis Meetup",
    ],
    "Cultural Events": [
        "Weekend Heritage Walk", "Classical Music Evening", "Diwali Community Celebration",
        "Karnataka Folk Dance Evening", "Poetry & Prose Circle", "Traditional Cooking Demo",
        "Community Rangoli Contest", "Cultural Potluck Festival", "Local History Talk",
    ],
    "Learning and Mentoring": [
        "Beginner Watercolour Workshop", "Resume Review & Career Mentoring", "Kids' Coding Basics",
        "Spoken English Practice Circle", "Financial Planning 101", "Gardening for Beginners",
        "Photography Walk & Talk", "Public Speaking Practice Group", "Yoga & Mindfulness Basics",
    ],
    "Family Activities": [
        "Family Picnic in the Park", "Kids' Storytelling Hour", "Family Movie Night",
        "Weekend Craft Session for Kids", "Parent-Child Cooking Class", "Family Fun Fair",
        "Kids' Talent Show", "Family Cycling Morning",
    ],
    "Fitness": [
        "Community Yoga Session", "Zumba in the Park", "Morning Bootcamp",
        "Badminton Meetup", "Cycling Club Ride", "Outdoor HIIT Session",
        "Weekend Football Kickabout", "Stretch & Mobility Class",
    ],
    "Volunteering": [
        "Community Park Cleanup", "Tree Plantation Drive", "Old Age Home Visit",
        "Blood Donation Camp", "Food Distribution Drive", "Lake Cleanup Volunteer Day",
        "Book Donation Drive", "Stray Animal Feeding Drive",
    ],
}

DESCRIPTIONS = [
    "A relaxed get-together for neighbours to connect, help each other out and build a stronger local community.",
    "Open to everyone in the neighbourhood — come as you are, bring a friend if you'd like.",
    "A small, friendly gathering focused on real connection rather than formality.",
    "Part of our regular neighbourhood meetups — newcomers always welcome.",
    "Organised by a verified local host. Details and any prep needed will be shared after your request is accepted.",
]


def main():
    print("Creating Whitefield hosts...")
    host_ids = []
    for email, name, img, verified in HOSTS:
        created = api("POST", "/auth/v1/admin/users", {
            "email": email,
            "password": f"Demo-{name.split()[0].lower()}-2026!",
            "email_confirm": True,
            "user_metadata": {"display_name": name},
        })
        uid = created["id"]
        host_ids.append(uid)
        api("PATCH", f"/rest/v1/profiles?id=eq.{uid}", {
            "avatar_url": f"https://i.pravatar.cc/150?img={img}",
            "is_verified": verified,
            "neighbourhood": random.choice(SUBLOCALITIES),
            "latitude": jitter(BASE_LAT, 0.015),
            "longitude": jitter(BASE_LON, 0.015),
        })
        print(f"  {name} -> {uid}")

    print("Creating 100 events...")
    total = 0
    now = datetime.now(timezone.utc)
    for category, titles in CATEGORIES.items():
        for title in titles:
            host_id = random.choice(host_ids)
            is_free = random.random() < 0.45
            price = "Free" if is_free else f"₹{random.choice([100, 150, 200, 250, 300, 400, 500])}"
            days_out = random.randint(1, 45)
            hour = random.choice([7, 8, 9, 16, 17, 18, 19, 20])
            event_time = (now + timedelta(days=days_out)).replace(
                hour=hour, minute=random.choice([0, 15, 30, 45]), second=0, microsecond=0
            )
            pic_id = random.randint(0, 1000)
            body = {
                "host_id": host_id,
                "title": title,
                "category": category,
                "description": random.choice(DESCRIPTIONS),
                "location": random.choice(SUBLOCALITIES),
                "event_time": event_time.isoformat(),
                "is_free": is_free,
                "price_label": price,
                "seats_available": random.randint(3, 25),
                "latitude": jitter(BASE_LAT),
                "longitude": jitter(BASE_LON),
                "cover_image_url": f"https://picsum.photos/id/{pic_id}/800/600",
            }
            api("POST", "/rest/v1/events", body)
            total += 1
    print(f"Done. Created {total} events across {len(CATEGORIES)} categories.")


if __name__ == "__main__":
    main()
