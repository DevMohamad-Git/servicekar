/// Public surface of the `lib/config/` layer. Mirrors
/// `lalafen/lib/config/config.dart`. Call sites import this barrel,
/// never the underlying subfolders.
library;

export 'l10n/l10n.dart';
export 'routes/app_router.dart';
export 'themes/app_themes.dart';
