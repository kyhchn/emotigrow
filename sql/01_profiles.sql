-- =============================================================================
-- 01_profiles.sql
-- User profile / info table with email, name and type (petani | pelanggan).
--
-- Run this first in Supabase: SQL Editor -> New query -> Run.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Table
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  email      text not null,
  name       text not null,
  type       text not null check (type in ('petani', 'pelanggan')),
  created_at timestamptz not null default now()
);

-- Optional: keep the email/name in sync if auth.users metadata changes.
-- (Comment out if you don't want this.)
create or replace function public.handle_new_profile()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, name, type)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data ->> 'name', ''),
    coalesce(new.raw_user_meta_data ->> 'type', 'pelanggan')
  );

  return new;
end;
$$;

-- -----------------------------------------------------------------------------
-- 2. Row Level Security
-- -----------------------------------------------------------------------------
alter table public.profiles enable row level security;

-- Signed-in user can read only their own row.
create policy "select own profile"
  on public.profiles for select
  using (auth.uid() = id);

-- Signed-in user can insert their own row.
create policy "insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- Signed-in user can update only their own row.
create policy "update own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);
