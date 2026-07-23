import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:servicar/config/config.dart';
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
