/// Root type for every failure raised by the domain or data layers.
///
/// Mirrors `lalafen/lib/core/errors/failure.dart` so a use case returning
/// `Either<Failure, T>` reads identically in both projects. Concrete
/// failure hierarchies (e.g. `CustomerFailure`) live alongside the
/// feature that owns them.
abstract class Failure {
  const Failure();

  /// Operator-facing, English-only error message. Localized variants
  /// are produced by the presentation layer via `AppLocalizations`.
  String get message;
}
