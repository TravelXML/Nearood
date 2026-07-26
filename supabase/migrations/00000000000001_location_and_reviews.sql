-- Adds location fields (for "near me" + distance) and a reviews table
-- (for host/event ratings), on top of 00000000000000_schema.sql.

alter table public.profiles
  add column if not exists latitude double precision,
  add column if not exists longitude double precision;

alter table public.events
  add column if not exists latitude double precision,
  add column if not exists longitude double precision,
  add column if not exists cover_image_url text;

-- ---------------------------------------------------------------------
-- reviews: rate a host after an event. One review per (event, reviewer).
-- ---------------------------------------------------------------------
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events (id) on delete cascade,
  host_id uuid not null references public.profiles (id) on delete cascade,
  reviewer_id uuid not null references public.profiles (id) on delete cascade,
  rating smallint not null check (rating between 1 and 5),
  comment text not null default '',
  created_at timestamptz not null default now(),
  unique (event_id, reviewer_id)
);

alter table public.reviews enable row level security;

create policy "Reviews are viewable by any signed-in user"
  on public.reviews for select
  to authenticated
  using (true);

create policy "Users can submit their own reviews"
  on public.reviews for insert
  to authenticated
  with check (auth.uid() = reviewer_id);

-- Convenience view: average rating + review count per host.
create or replace view public.host_ratings as
  select host_id, avg(rating)::numeric(3,2) as avg_rating, count(*) as review_count
  from public.reviews
  group by host_id;

grant select on public.host_ratings to authenticated;
