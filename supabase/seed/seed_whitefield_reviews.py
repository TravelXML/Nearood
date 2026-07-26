#!/usr/bin/env python3
"""Adds a couple of reviews per Whitefield host so ratings aren't empty.
Run after seed_whitefield_100.py.

Usage:
  PROJECT_URL="https://xxxx.supabase.co" SERVICE_ROLE_KEY="..." python3 seed_whitefield_reviews.py
"""
import json
import os
import random
import urllib.request

PROJECT_URL = os.environ["PROJECT_URL"]
SERVICE_ROLE_KEY = os.environ["SERVICE_ROLE_KEY"]

random.seed(7)

# Hardcoded from seed_whitefield_100.py's output — the GoTrue admin users
# list endpoint doesn't actually honour the `email` query filter (returns
# the same page regardless), so looking these up dynamically isn't reliable.
HOST_IDS = [
    "39cab46d-fc07-45a4-bac0-0f8ec9e4f057",  # Deepa Nair
    "c99361a3-ab30-4840-a431-a4f97bcfb82d",  # Arjun Reddy
    "7d6aa48e-35ff-490e-97b0-136a5cd128c2",  # Meera Krishnan
    "0e9f392b-8363-443f-83c6-b9cd645d2354",  # Vikram Rao
    "66e25458-4e25-4a71-9230-8aa264ffddc3",  # Lakshmi Iyengar
    "415f0b41-7e4a-4c0e-8423-e0027a31e887",  # Suresh Kumar
    "cdc84b69-42f6-468b-93dc-058e4b39689a",  # Ananya Bhat
    "2cba45ef-74bf-457e-ab44-abea3231978e",  # Rahul Gowda
]

COMMENTS = [
    "Really well organised, would join again.",
    "Warm host, felt welcomed immediately.",
    "Great way to meet neighbours, exactly as described.",
    "Punctual and easy to communicate with.",
    "Lovely experience, small thoughtful touches throughout.",
    "Good turnout, well coordinated from start to finish.",
]


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


def main():
    host_ids = HOST_IDS

    total = 0
    for host_id in host_ids:
        events = api("GET", f"/rest/v1/events?host_id=eq.{host_id}&select=id&limit=3")
        reviewers = [h for h in host_ids if h != host_id]
        for event in events[:2]:
            reviewer_id = random.choice(reviewers)
            api("POST", "/rest/v1/reviews", {
                "event_id": event["id"],
                "host_id": host_id,
                "reviewer_id": reviewer_id,
                "rating": random.choice([4, 4, 5, 5, 5]),
                "comment": random.choice(COMMENTS),
            })
            total += 1
    print(f"Done. Added {total} reviews.")


if __name__ == "__main__":
    main()
