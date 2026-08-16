-- Nearood initial schema.
-- Run this once in your Supabase project's SQL Editor
-- (Dashboard -> SQL Editor -> New query -> paste -> Run).

-- ---------------------------------------------------------------------
-- profiles: one row per auth.users row, created automatically on signup.
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  neighbourhood text,
  avatar_url text,
  is_verified boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Profiles are viewable by any signed-in user"
  on public.profiles for select
  to authenticated
  using (true);

create policy "Users can update their own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id);

-- Auto-create a profile row whenever a new auth user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data ->> 'display_name');
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------
-- events
-- ---------------------------------------------------------------------
create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  host_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  category text not null,
  description text not null default '',
  location text not null default '',
  event_time timestamptz not null,
  is_free boolean not null default true,
  price_label text not null default 'Free',
  seats_available integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.events enable row level security;

create policy "Events are viewable by any signed-in user"
  on public.events for select
  to authenticated
  using (true);

create policy "Hosts can insert their own events"
  on public.events for insert
  to authenticated
  with check (auth.uid() = host_id);

create policy "Hosts can update their own events"
  on public.events for update
  to authenticated
  using (auth.uid() = host_id);

create policy "Hosts can delete their own events"
  on public.events for delete
  to authenticated
  using (auth.uid() = host_id);

-- ---------------------------------------------------------------------
-- join_requests: a participant asking to join an event.
-- ---------------------------------------------------------------------
create table if not exists public.join_requests (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events (id) on delete cascade,
  requester_id uuid not null references public.profiles (id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'accepted', 'rejected', 'cancelled')),
  created_at timestamptz not null default now(),
  unique (event_id, requester_id)
);

alter table public.join_requests enable row level security;

create policy "Requesters can view their own requests"
  on public.join_requests for select
  to authenticated
  using (auth.uid() = requester_id);

create policy "Hosts can view requests for their events"
  on public.join_requests for select
  to authenticated
  using (
    exists (
      select 1 from public.events e
      where e.id = event_id and e.host_id = auth.uid()
    )
  );

create policy "Requesters can create their own requests"
  on public.join_requests for insert
  to authenticated
  with check (auth.uid() = requester_id);

create policy "Hosts can update the status of requests for their events"
  on public.join_requests for update
  to authenticated
  using (
    exists (
      select 1 from public.events e
      where e.id = event_id and e.host_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------
-- verification_requests: self-declared Aadhaar/govt ID submissions.
-- NOT validated against UIDAI or any government system — this is a
-- placeholder for human/admin review, not real identity verification.
-- ---------------------------------------------------------------------
create table if not exists public.verification_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  method text not null default 'aadhaar',
  id_last4 text,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles (id)
);

alter table public.verification_requests enable row level security;

create policy "Users can view their own verification requests"
  on public.verification_requests for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Users can submit their own verification requests"
  on public.verification_requests for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Approving/rejecting requests (and flipping profiles.is_verified) is
-- left to an admin acting via the Supabase Table Editor / service role
-- for now, since there's no admin app yet.
