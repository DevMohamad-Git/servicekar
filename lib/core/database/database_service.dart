import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

/// Process-wide Isar lifecycle wrapper for the ServiceKar app.
///
/// One [DatabaseService] per process. The single instance is opened
/// once during `configureDependencies()` (see
/// `lib/injection/injection.dart`) and lives for the entire app
/// lifetime — it is never disposed between route pushes because
/// the [ProviderContainer] that owns it is reused across them.
///
/// Why a thin wrapper instead of handing callers a raw [Isar]:
///   * Centralises the "open once, close on dispose" contract so
///     the bootstrap call site stays mechanical.
///   * Hides the `path_provider` resolution behind a default the
///     tests override through [DatabaseService.open]'s
///     [directory] parameter.
///   * Provides a clearly-named DI seam (`isarInstanceProvider`
///     in `lib/injection/global_providers.dart`) without leaking
///     the `isar_community` package symbol into feature modules.
///   * Future schema additions (Service, Invoice, Payment, …)
///     compose into the same `Isar.open([...])` invocation
///     without touching this file.
class DatabaseService {
  DatabaseService._(this.isar);

  /// The opened Isar instance. Stable for the entire app lifetime.
  final Isar isar;

  /// Open the project's default Isar database.
  ///
  /// Parameters:
  ///   * [schemas] — every collection schema the database needs
  ///     at open time. Isar v3 throws
  ///     `IsarError: At least one schema needs to be provided`
  ///     when this list is empty, so the *first* feature to
  ///     introduce an `@collection` class is responsible for
  ///     (a) importing its generated schema,
  ///     (b) wiring the call here from `configureDependencies()`,
  ///     (c) listing that schema in [schemas].
  ///     This infrastructure-only shipment deliberately leaves
  ///     `open()` un-called — see `lib/injection/injection.dart`
  ///     for the documented call site.
  ///   * [name] — logical database name within the project
  ///     directory. Mirrors the app name and gives
  ///     multi-environment setups (dev / prod / e2e) distinct
  ///     stores when feature flags demand it.
  ///   * [directory] — overrides the default `path_provider`
  ///     lookup. Used by tests that need a temp dir.
  static Future<DatabaseService> open({
    required List<CollectionSchema<dynamic>> schemas,
    String name = 'servicar',
    String? directory,
  }) async {
    final resolvedDir =
        directory ?? (await getApplicationDocumentsDirectory()).path;
    final isar = await Isar.open(
      schemas,
      directory: resolvedDir,
      name: name,
      // `kDebugMode` flips the inspector on for development work
      // (per Isar's docs, the inspector probes the running DB via
      // a dev-only debug bridge that must never ship to prod).
      inspector: kDebugMode,
    );
    return DatabaseService._(isar);
  }

  /// Time-of-check / time-of-use-friendly close.
  ///
  /// Safe to call after [isar] was already closed. Today's app
  /// lifecycle never disposes this service, but exposing the
  /// method keeps tests and a future `Provider.onDispose` flow
  /// honest without re-introducing the Isar import into callers.
  Future<void> close() async {
    if (isar.isOpen) {
      await isar.close();
    }
  }
}
