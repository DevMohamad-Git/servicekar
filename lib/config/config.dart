/// Public surface of the `lib/config/` layer.
///
/// Funnels every chrome-level concern (`l10n/`, `routes/`,
/// `themes/`) through one barrel so `MaterialApp.router(...)`
/// consumers only need a single import. Mirrors
/// `lalafen/lib/config/config.dart` one-to-one. New config
/// subfolders should also be `export`ed here so the barrel stays
/// the single entry-point for chrome-level wiring.
library;

export 'l10n/l10n.dart';
export 'routes/app_router.dart';
export 'themes/app_themes.dart';
