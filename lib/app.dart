import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'config/l10n/arb/app_localizations.dart';
import 'config/themes/app_themes.dart';
import 'core/constants/general_constants.dart';
import 'injection/global_providers.dart';

/// Root widget of the Servicar app.
///
/// Reads the live `appRouterProvider` (registered in
/// `lib/injection/global_providers.dart`) so a router swap (test,
/// flavor, navigation guard) flows through Riverpod without
/// re-creating MaterialApp.
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
      darkTheme: AppThemes.dark,
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
