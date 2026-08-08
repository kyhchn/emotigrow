-- =============================================================================
-- 02_auto_register_trigger.sql   (OPTIONAL)
-- Auto-create a `profiles` row whenever a new auth user signs up.
--
-- Use this ONLY if you keep "Confirm email" ENABLED in Supabase.
--
-- Why?
--   When email confirmation is ON, the app's `signUp()` gets no session and
--   thus cannot insert the profile row itself. This trigger makes the database
--   create the row automatically from the auth user's email + metadata.
--
-- Note:
--   The app must send `name` and `type` inside the sign-up metadata so this
--   trigger can pick them up:
--     supabase.auth.signUp(
--       email: ...,
--       password: ...,
--       data: { 'name': ..., 'type': ... },
--     )
--   If a `name` isn't provided yet it defaults to '' and `type` to 'pelanggan'.
--
-- Run this AFTER 01_profiles.sql.
-- =============================================================================

-- Attach the handler defined in 01_profiles.sql to new auth sign-ups.
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_profile();
