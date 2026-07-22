import 'dart:developer' as dev;

/// Process-wide logger.
///
/// Wraps `dart:developer.log` so the rest of the app never reaches into
/// `dart:developer` directly. Keeping the seam here means we can later
/// route messages to Sentry / Crashlytics / a file without touching
/// call sites.
///
/// Levels are intentionally minimal — `info`, `warn`, `error` — and the
/// underlying `log` call uses a stable `name` (`Servicar`) so log
/// filters in DevTools pick it up immediately.
class AppLogger {
  const AppLogger._();

  static const String _name = 'Servicar';

  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(message, name: _name, level: 800, error: error, stackTrace: stackTrace);
  }

  static void warn(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(message, name: _name, level: 900, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(message, name: _name, level: 1000, error: error, stackTrace: stackTrace);
  }
}
