/// Central, single-source-of-truth configuration for the app.
///
/// Replace the placeholder values below with your own credentials, then the
/// rest of the app will pick them up automatically.
class AppConfig {
  AppConfig._();

  // ---------------------------------------------------------------------------
  // Supabase  (used for authentication + user info)
  // ---------------------------------------------------------------------------
  // Find these in the Supabase dashboard:
  // Project Settings -> API -> Project URL + "publishable" (anon) public key.
  static const String supabaseUrl = 'https://gyuuswzsioqgyvguzhqx.supabase.co';
  static const String supabasePublishableKey = 'sb_publishable_SRIstunHzj9L16-Gl4GpcA_zPVkqZ8z';

  // ---------------------------------------------------------------------------
  // Splash screen
  // ---------------------------------------------------------------------------
  /// Path to the splash image asset.
  ///
  /// To use your own splash image, simply replace the file at
  /// `assets/images/splash.png` (keeping the same name), or point this field at
  /// a different file under `assets/images/` and rebuild.
  static const String splashImageAsset = 'assets/images/splash.png';

  /// How long the splash screen stays on screen before navigating away.
  static const Duration splashDuration = Duration(seconds: 2);
}