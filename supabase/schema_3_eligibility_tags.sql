-- "Who it's for" tags on events, e.g. Senior-friendly, Women-only,
-- Family-friendly, Accessibility support.
alter table public.events
  add column if not exists eligibility_tags text[] not null default '{}';
