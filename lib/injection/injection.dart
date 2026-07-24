/// Public barrel for the injection module + the project-wide
/// DI bootstrap entry point.
///
/// Lifecycle expectations:
///   1. `WidgetsFlutterBinding.ensureInitialized()` must run
///      *before* any provider whose constructor talks to a
///      platform channel (preferences, path_provider, share_plus,
///      Isar, …). Today no such provider exists, but the rule
///      still applies because adding `Isar.open(...)` here will
///      silently fail otherwise.
///   2. `configureDependencies()` returns a live [ProviderContainer]
///      that `main.dart` passes to `UncontrolledProviderScope`.
///      That container is the single owner of every provider for
///      the app's lifetime.
///   3. Feature providers (repositories, use cases, controllers)
///      stay lazily discovered through `ref.watch`. They are NOT
///      registered here — see the README's "Provider Organization"
///      table for the authorized tiers. New features scale
///      infinitely without touching this file.
///
/// Tests override a single provider by building a fresh
/// `ProviderContainer(overrides: [...])` and passing it to
/// `UncontrolledProviderScope` themselves; this helper does not
/// own that concern on purpose.
///
/// Note on the README's `injection/feature_injection/[feature]_providers.dart`
/// tier: that folder is now in use. The customer feature's
/// repositories + use-case providers live in
/// `injection/feature_injection/customer_providers.dart`, matching the
/// README `Provider Organization` table's "Feature-specific" row. New
/// features MUST register their providers under
/// `injection/feature_injection/[feature]_providers.dart` per the
/// README.
library;

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'global_providers.dart';

export 'global_providers.dart';

/// Construct the project's [ProviderContainer] before [runApp].
///
/// Returns the live [ProviderContainer] that `main.dart` hands to
/// `UncontrolledProviderScope`, so the DI graph is built exactly
/// once and never re-created between route pushes.
///
/// Why it is async — keeps a future `await Isar.open(...)`,
/// preferences warm-up, or locale load fenced inside this
/// helper instead of leaking into `main.dart`. Today the body is
/// effectively sync; the `async`/`await` shape is forward-looking
/// so the public signature never has to change.
///
/// Why there is NO `overrides` parameter — Riverpod's own
/// `ProviderScope(overrides: [...])` accepts overrides only on
/// a freshly-built scope. Wrapping the container construction
/// here would either force production code into a test-flavoured
/// shape or hide the standard mechanism. If a future caller
/// absolutely needs construction-time overrides, build the
/// container manually — DO NOT grow this signature; the helper
/// exists to centralise *bootstrap*, not to swallow every
/// Riverpod knob.
///
/// Eager reads on [envProvider], [appHelperProvider] and
/// [appRouterProvider] surface failures BEFORE the first frame.
/// Everything else stays lazy, intentionally:
///
///   * Importing feature repositories here would force every
///     feature module to load on cold start.
///   * It would couple this helper to every new feature — every
///     feature would create a merge conflict on this file.
///   * It would fight Riverpod's own family / auto-dispose model.
Future<ProviderContainer> configureDependencies() async {
  // ─── Isar bootstrap (deliberately no-op today) ─────────────────
  //
  //   final db = await DatabaseService.open(
  //     schemas: [/* first @collection schema will be listed here */],
  //   );
  //   // …then build the container with the override below.
  //
  // Why this stays commented out: Isar v3 throws
  // `IsarError: At least one schema needs to be provided` when
  // `Isar.open` is invoked with an empty schemas list, and the
  // task that introduces this file is ordered ahead of any
  // `@collection` class. The first feature to ship such a class
  // (Customer Collection / Service Collection / …) is responsible
  // for:
  //   (a) running `dart run build_runner build` to generate its
  //       collection schema,
  //   (b) importing the generated schema above,
  //   (c) uncommenting the two open() lines below,
  //   (d) listing itself in the `schemas:` array.
  // That preserves the README § SSoT "open once in bootstrap"
  // guarantee without forcing a writeTxn-friendly persistence
  // layer on day 0 (when no collection has shipped yet).
  //
  // The override list below is intentionally `const []` so the
  // container can be built today; once (a)–(d) land, the call
  // site grows to:
  //   final container = ProviderContainer(
  //     overrides: [isarInstanceProvider.overrideWithValue(db.isar)],
  //   );
  final container = ProviderContainer(overrides: const []);

  // Eager globals whose construction has setup work (or whose
  // future construction will — AppHelper is reserved for the
  // planned SnackBar/Toast queue, AppRouter walks the @AutoRoute
  // graph). Keeping these reads here means a misbehaving global
  // surfaces in `main()` and not in the first frame.
  container.read(envProvider);
  container.read(appHelperProvider);
  container.read(appRouterProvider);

  return container;
}
