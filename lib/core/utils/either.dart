/// A minimal, dependency-free [Either] for Clean Architecture error handling.
///
/// - [Left] carries an error/failure value.
/// - [Right] carries a success value.
///
/// Inspired by `dartz`/`fpdart`, but implemented with Dart 3 `sealed class`
/// so the analyzer enforces exhaustive pattern matching at the call site.
///
/// Usage:
/// ```dart
/// final result = await someUseCase();
/// return result.fold(
///   (failure) => /* handle failure */,
///   (data) => /* handle success */,
/// );
/// ```
library;

sealed class Either<L, R> {
  const Either();

  /// Returns true when this holds an error ([Left]).
  bool get isLeft => this is Left<L, R>;

  /// Returns true when this holds a success ([Right]).
  bool get isRight => this is Right<L, R>;

  /// Pattern-matches on the value: [onLeft] runs for failures,
  /// [onRight] runs for successes. Both branches must return the same type [T].
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);

  /// Returns the success value or `null` when this is a [Left].
  R? get rightOrNull => switch (this) {
        Right<L, R>(:final value) => value,
        Left<L, R>() => null,
      };

  /// Returns the failure value or `null` when this is a [Right].
  L? get leftOrNull => switch (this) {
        Left<L, R>(:final value) => value,
        Right<L, R>() => null,
      };
}

/// Failure side of [Either]. Holds an error/failure value of type [L].
final class Left<L, R> extends Either<L, R> {
  const Left(this.value);

  final L value;

  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) => onLeft(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Left<L, R> && other.value == value);

  @override
  int get hashCode => (value as Object?).hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Success side of [Either]. Holds a value of type [R].
final class Right<L, R> extends Either<L, R> {
  const Right(this.value);

  final R value;

  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) => onRight(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Right<L, R> && other.value == value);

  @override
  int get hashCode => (value as Object?).hashCode;

  @override
  String toString() => 'Right($value)';
}

/// Sentinel for "no meaningful success value". Used in repository methods
/// such as `delete` that need an `Either<Failure, T>` contract without
/// smuggling `void` through the type system.
final class Unit {
  const Unit._();
  static const Unit instance = Unit._();

  @override
  String toString() => 'Unit';
}
