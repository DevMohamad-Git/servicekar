import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app.dart';
import 'injection/injection.dart';

Future<void> main() async {
  // Three error channels for full coverage — the Flutter docs'
  // canonical pattern, mirrored from Lalafen:
  //   1. FlutterError.onError
  //        Sync framework errors during build / layout / paint.
  //   2. PlatformDispatcher.instance.onError
  //        Async errors from platform channels / isolates that
  //        escape the zone we set up below.
  //   3. runZonedGuarded -> onError
  //        Async errors thrown before the platform dispatcher
  //        hook is registered (e.g. inside `configureDependencies`
  //        while we are still building the DI graph).
  //
  // We log through `dart:developer`'s `log()` so the records show
  // up in DevTools with a stable `name:` tag; replace with
  // Crashlytics / Sentry sinks once the project adds either.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ─── Edge-to-edge system UI ─────────────────────────────────
      // The customer-page header draws a single white surface from
      // the physical top edge of the window down through the
      // toolbar, so the OS status bar strip must be transparent
      // (no disconnected grey / white rectangle above the app).
      // Icons stay dark (Brightness.dark on Android,
      // Brightness.light on iOS — Apple flips the polarity on the
      // legacy status-bar API, so `light` = dark glyphs on a
      // light background). The navigation bar keeps the same
      // dark-icon treatment against the bottom-of-window chrome
      // so the whole frame reads as one immersive sheet.
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
      );
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );

      FlutterError.onError = (details) {
        log(
          details.exceptionAsString(),
          name: 'FlutterError',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        log(
          'Platform-dispatcher error',
          name: 'PlatformDispatcher',
          error: error,
          stackTrace: stack,
        );
        // Return `true` to mark the error handled — we already
        // logged it. Flip to `false` once Crashlytics is wired so
        // the OS also receives the report.
        return true;
      };

      // Live-Persistence anchor: `configureDependencies()` builds
      // the single ProviderContainer that owns every global for
      // the entire app lifetime. The `await` is forward-looking —
      // today the body has no awaits, but future `await Isar.open(...)`
      // / preferences warm-up inside `configureDependencies()` will
      // reuse this await and avoid changing the call site again.
      final providerContainer = await configureDependencies();

      runApp(
        UncontrolledProviderScope(
          container: providerContainer,
          child: const App(),
        ),
      );
    },
    (error, stackTrace) {
      log(
        'Uncaught zone error',
        name: 'uncaught',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}
