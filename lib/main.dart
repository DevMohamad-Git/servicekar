import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app.dart';
import 'injection/global_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  // Live-Persistence anchor: the ProviderContainer is created once
  // here and handed to UncontrolledProviderScope, which keeps it
  // alive for the entire app lifetime. Mirrors Lalafen's main.dart.
  final providerContainer = ProviderContainer();

  // Touch the global providers so any eager initializers (e.g.
  // audio service, preferences) run BEFORE the first frame.
  providerContainer.read(envProvider);
  providerContainer.read(appHelperProvider);
  providerContainer.read(appRouterProvider);

  runApp(
    UncontrolledProviderScope(
      container: providerContainer,
      child: const App(),
    ),
  );
}
