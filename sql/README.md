# SQL Schema

Database schema for the Emotigrow app (Supabase / PostgreSQL).

## Files

| File | Purpose |
|------|---------|
| `01_profiles.sql` | Creates the `profiles` table (email, name, type = petani/pelanggan), enables Row Level Security, and adds per-user policies. Also defines the profile handler function used by the optional trigger. |
| `02_auto_register_trigger.sql` | **Optional.** Auto-creates a `profiles` row on auth sign-up. Only needed when email confirmation is enabled. |

## How to run

In the Supabase dashboard:

1. Open **SQL Editor** → *New query*.
2. Paste the contents of `01_profiles.sql` → **Run**.
3. (Optional) If email confirmation is **enabled**, also run `02_auto_register_trigger.sql`.

## Resulting schema

```
profiles
  id         uuid      primary key -> auth.users(id), on delete cascade
  email      text      not null
  name       text      not null
  type       text      not null  check (type in ('petani', 'pelanggan'))
  created_at timestamptz not null default now()
```

### Row Level Security policies

- `select own profile` — user can read only their own row (`auth.uid() = id`)
- `insert own profile`  — user can insert their own row
- `update own profile`  — user can update only their own row
