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
/// tier: that folder does not yet exist. Today's customer feature
/// colocates its repositories + use-case providers in
/// `presentation/customer/logic/customer_use_case_providers.dart`,
/// which is a *known deviation* from the authorised tier —
/// NOT an equally valid alternative. New features MUST register
/// their providers under `injection/feature_injection/[feature]_providers.dart`
/// per the README, and the customer module should be migrated to
/// match during the first feature that follows it.
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
  final container = ProviderContainer();

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
