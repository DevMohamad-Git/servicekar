import 'package:flutter/widgets.dart';
import 'package:servicar/config/l10n/arb/app_localizations.dart';

/// Localization barrel mirroring `lalafen/lib/config/l10n/l10n.dart`.
///
/// ARB sources live at `lib/config/l10n/arb/app_fa.arb` (Persian MVP
/// source) and `lib/config/l10n/arb/app_en.arb` (tool fallback; English
/// is not user-facing in MVP). The generated `app_localizations.dart`
/// and locale-specific subclasses (`app_localizations_fa.dart`,
/// `app_localizations_en.dart`) are emitted by `flutter gen-l10n`
/// into the same `arb/` directory.
///
/// Call sites reach strings through `context.l10n.<key>` thanks to
/// the inline extension below — that satisfies README §
/// Localization's `context.l10n.save` requirement without forcing
/// every file to import `AppLocalizations` directly.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
