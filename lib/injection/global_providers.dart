import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../config/routes/app_router.dart';
import '../core/environment/env.dart';
import '../core/environment/env_dev.dart';
import '../core/utils/app_helper.dart';

/// Global providers — process-wide, never disposed while the app is
/// alive. Mirrors the Lalafen layout (`lib/injection/global_providers.dart`)
/// exactly: every global is long-lived.
///
/// This file uses the *manual* `Provider`/`Provider` API rather than
/// `@Riverpod(keepAlive: true)` because `build_runner` cannot run in
/// this sandbox (no `pub.dev` access). Manual `Provider`s here are
/// effectively `keepAlive` for the app's lifetime because they are
/// instantiated lazily and never auto-disposed by the container
/// until the container itself is torn down — and the container here
/// outlives every page navigation by construction.

/// Active [Env]. Defaults to [EnvDev]; swap for [EnvProd] once a real
/// release environment exists.
final envProvider = Provider<Env>((ref) => EnvDev());

/// [AppHelper] instance injected into every page through Riverpod.
/// Lifetime equals the app's.
final appHelperProvider = Provider<AppHelper>((ref) => AppHelper(ref));

/// Single [AppRouter] bound to the app's lifetime.
final appRouterProvider = Provider<AppRouter>((ref) => AppRouter());

/// Project-wide Isar instance.
///
/// Today this provider is intentionally NOT overridden in
/// `configureDependencies()`: Isar v3 throws when `Isar.open` is
/// called with an empty schemas list, and the infrastructure task
/// that introduces this file is ordered *ahead* of any
/// `@collection` class. Reading the provider today therefore
/// raises a [StateError] that points future engineers back at the
/// bootstrap comment so the missing `open()` is obvious in the log.
///
/// Once the first `@collection` class ships (Customer Collection,
/// Service Collection, …) the bootstrap in
/// `lib/injection/injection.dart` will:
///   1. `await DatabaseService.open(schemas: [...])` once;
///   2. add `isarInstanceProvider.overrideWithValue(db.isar)` to
///      the `ProviderContainer(overrides:)` list.
///
/// Pattern rationale: the global must be readable from any feature
/// module as a synchronous [Isar] handle (Library-spec matches
/// the README's "Open-Once-Source-of-Truth" rule), so the async
/// open happens at bootstrap and the override eliminates the
/// `AsyncValue` ladder at every call site.
final isarInstanceProvider = Provider<Isar>((ref) {
  throw StateError(
    'isarInstanceProvider was read before Isar was opened in '
    'configureDependencies(). Either:\n'
    '  • no @collection has been shipped yet (the bootstrap is '
    'deliberately no-op until the first schema arrives), OR\n'
    '  • a feature reached for Isar before configureDependencies() '
    'finished.\n'
    'See `lib/injection/injection.dart` for the bootstrap recipe '
    'and `lib/core/database/database_service.dart` for the open '
    'contract.',
  );
});
