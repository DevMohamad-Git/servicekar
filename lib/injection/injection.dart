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

import '../core/database/database_service.dart';
import '../features/customer/data/models/customer_isar.dart';
import '../features/customer/data/models/invoice_isar.dart';
import '../features/customer/data/models/payment_isar.dart';
import '../features/customer/data/models/service_isar.dart';
import 'global_providers.dart';

export 'global_providers.dart';

/// Construct the project's [ProviderContainer] before [runApp].
///
/// Returns the live [ProviderContainer] that `main.dart` hands to
/// `UncontrolledProviderScope`, so the DI graph is built exactly
/// once and never re-created between route pushes.
///
/// Why it is async — keeps the `await DatabaseService.open(...)`,
/// `await Isar.open(...)`, future preferences warm-up, or locale
/// load fenced inside this helper instead of leaking into
/// `main.dart`.
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
///
/// ─── Isar bootstrap ───────────────────────────────────────────────
/// `await DatabaseService.open(schemas: [...])` runs once here.
/// The returned [Isar] lives for the entire process and is handed
/// to every Isar-aware provider via
/// `isarInstanceProvider.overrideWithValue(db.isar)`.
///
/// **Phase 2 — Linked-data foundation:** the four MVP collections
/// (Customer, Service, Invoice, Payment) are now opened
/// together. Across collections the link is a *plain `String`
/// foreign key* (`customerUuid`, `invoiceUuid`) on the child row:
/// the alternative `IsarLink<…>` would silently detach every link
/// whenever a customer is re-imported (the `replace: true` +
/// `Isar.autoIncrement` reallocates the internal int Id).
/// Cross-collection writes, reads, and cascade-delete policies
/// are owned by the *repository layer* — that work ships in Phase 3.
///
/// Future schemas (any new domain collection) compose into the
/// same `Isar.open([...])` invocation without touching this
/// contract — just append to the `schemas:` list and the rebuild
/// regenerates their `*.g.dart` part files.
Future<ProviderContainer> configureDependencies() async {
  final db = await DatabaseService.open(
    schemas: [
      CustomerIsarSchema,
      ServiceIsarSchema,
      InvoiceIsarSchema,
      PaymentIsarSchema,
    ],
  );
  final container = ProviderContainer(
    overrides: [isarInstanceProvider.overrideWithValue(db.isar)],
  );

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
