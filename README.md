# Emotigrow (Flutter)

Flutter starter app using:
- **Supabase** — authentication + user/profile info
- **Firebase Realtime Database** — realtime data (in addition to Supabase)

The app opens with an image-driven **splash screen** that you can customize.

## Project structure

```
lib/
  main.dart                     # Entry point: initializes Supabase + Firebase
  core/app_config.dart          # Credentials + splash settings (edit me)
  services/
    supabase_service.dart       # Auth + user info wrapper
    firebase_rtdb_service.dart  # Realtime DB wrapper
  screens/
    splash_screen.dart          # Image-driven splash (edit to swap image)
    login_screen.dart           # Email/password sign in & sign up
    home_screen.dart            # Shows user info + pings Realtime DB
assets/images/splash.png        # Placeholder splash image (replace this)
```

## Setup

1. **Install the Flutter deps**

   ```sh
   flutter pub get
   ```

2. **Configure Supabase** (auth + user info)
   - In the [Supabase dashboard](https://app.supabase.com) → Project Settings → API,
     copy the **Project URL** and the **publishable (anon) key**.
   - Paste them into `lib/core/app_config.dart`:
     ```dart
     static const supabaseUrl = 'https://gyuuswzsioqgyvguzhqx.supabase.co';
     static const supabasePublishableKey = 'sb_publishable_SRIstunHzj9L16-Gl4GpcA_zPVkqZ8z';
     ```

   - **Create the `profiles` table.** In the Supabase dashboard open
     **SQL Editor** → *New query*, paste the script below, and run it.
     This creates the table (with `email`, `name`, and a `type` constrained to
     `petani`/`pelanggan`), enables Row Level Security, and adds the policies so
     a signed-in user can insert their own row and read/update only their own.

     ```sql
     -- User profile / info table (email, name, type = petani | pelanggan)
     create table if not exists public.profiles (
       id         uuid primary key references auth.users (id) on delete cascade,
       email      text not null,
       name       text not null,
       type       text not null check (type in ('petani', 'pelanggan')),
       created_at timestamptz not null default now()
     );

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
     ```

   - **Disable email confirmation for immediate sign-up** (simplest for dev):
     Authentication → Providers → Email → turn **Off** "Confirm email".
     With confirmation off, the app inserts the profile row right after sign-up.
     If you keep confirmation **on**, the app can't insert the row until the
     email is verified — see the notes in `lib/services/supabase_service.dart`.

   - The flow the app uses:
     - **Sign up:** creates the auth user, then inserts a row into `profiles`
       with `{ id, email, name, type }`.
     - **Sign in:** authenticates with email + password.
     - **Load info:** `fetchProfile()` reads the row by the signed-in user's id;
       the home screen shows `name` and `type`.

3. **Configure Firebase Realtime Database**
   - Follow the Firebase setup for your platform(s) and drop in the config file:
     - iOS/macOS → `GoogleService-Info.plist`
     - Android → `google-services.json` (add the `google-services` Gradle plugin)
     - Web → Firebase `[DEFAULT]` options / script tags
   - The RTDB rules should allow read/write for your use case.

## Customizing the splash screen

The splash is a single, full-bleed image. Swap the image by **either**:

- Replacing the file at `assets/images/splash.png` (keep the same name), **or**
- Pointing `AppConfig.splashImageAsset` to a different file under
  `assets/images/`.

Then rebuild:

```sh
flutter run
```

You can also tweak the on-screen duration via
`AppConfig.splashDuration`.

## Testing

```sh
flutter analyze
flutter test
```
