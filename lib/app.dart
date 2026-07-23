import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/config/config.dart';
// Direct import for `AppLocalizations.delegate` and
// `AppLocalizations.supportedLocales` (static members). Mirrors
// `lalafen/lib/app.dart`: the Lalafen-aligned `l10n.dart` barrel
// does NOT re-export `AppLocalizations` (`export` would diverge
// from the upstream pattern), so the static surface reaches us
// only via the original file under `arb/`. The build-context
// extension `context.l10n.X` continues to flow through
// `package:servicar/config/config.dart` → `l10n/l10n.dart`.
import 'package:servicar/config/l10n/arb/app_localizations.dart';
import 'core/constants/general_constants.dart';
import 'injection/global_providers.dart';

/// Root widget of the Servicar app.
///
/// Reads the live `appRouterProvider` (registered in
/// `lib/injection/global_providers.dart`) so a router swap (test,
/// flavor, navigation guard) flows through Riverpod without
/// re-creating MaterialApp.
///
/// Theme wiring mirrors `lalafen/lib/app.dart`: a single
/// `AppThemes.light` (no `darkTheme:` argument — Lalafen ships
/// light-only by design, see `lib/config/themes/app_themes.dart`
/// for the rationale).
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      restorationScopeId: GeneralConstants.kRestorationScopeId,
      routerConfig: appRouter.config(),
      theme: AppThemes.light,
      // ─── Persian RTL MVP (per README § Localization) ────────────
      // MVP is Persian-only; the user-facing language is forced to
      // `Locale('fa')`. Switching languages is out of scope for the
      // MVP and will be wired via a `themeMode`-style provider in a
      // future task. MaterialApp auto-applies `Directionality.rtl`
      // for any RTL Locale (fa is RTL), so no manual wrap is needed.
      // Digits stay Latin across the app per product decision — this
      // aligns with Persian numeric conventions for technical users
      // (prices, dates, phone numbers, invoice IDs).
      locale: const Locale('fa'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
