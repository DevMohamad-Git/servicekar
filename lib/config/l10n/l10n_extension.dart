import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

/// `BuildContext.l10n` shortcut for the project's [AppLocalizations].
///
/// Mirrors the convention flagged in README § Localization
/// (`context.l10n.save` etc.). Folds the verbose
/// `AppLocalizations.of(context)!` lookup into a single property so
/// every call site reads `context.l10n.<key>` instead of a three-
/// token chain. Underlying [Localizations.of] returns non-null
/// because:
///   * `l10n.yaml` sets `nullable-getter: false`, so gen-l10n
///     produces non-nullable getters on the abstract class.
///   * `MaterialApp.router` in `lib/app.dart` registers
///     [AppLocalizations.delegate] in `localizationsDelegates`,
///     so a non-null instance is always available inside any
///     descendant widget's `context`.
///
/// Rejected alternatives (kept here so future contributors do not
/// re-propose them):
///   * Project-wide singleton (`AppLocalizations.instance`) —
///     wrong because `Localizations.of` is intentionally
///     context-bound: a widget tree can swap locale at runtime
///     and the singleton would lag behind.
///   * Custom `TranslatorService` wrapper — pure indirection over
///     gen-l10n's already-concise API. Adds a layer for no
///     behaviour gain at the current project size.
extension LocalizationX on BuildContext {
  /// Shorthand for `AppLocalizations.of(this)`. Read via
  /// `context.l10n.appName`, `context.l10n.save`, etc.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
