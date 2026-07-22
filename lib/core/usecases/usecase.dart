import '../utils/either.dart';
import '../errors/failure.dart';

/// Generic UseCase contract.
///
/// Every domain use case implements [call] and returns
/// `Either<Failure, T>`. Mirrors
/// `lalafen/lib/core/usecases/usecase.dart` so the call sites read
/// identically in both projects.
///
/// Servicar keeps its dependency-free local [Either] today (no
/// `fpdart` in pubspec). The contract here is either-compatible, so a
/// future swap to fpdart only has to change the import in this file.
abstract class UseCase<T, Params> {
  const UseCase();

  Future<Either<Failure, T>> call(Params params);
}

/// Sentinel for "no parameters" — passed to use cases that don't need
/// any input (e.g. `GetCustomersUseCase.call()`).
class NoParams {
  const NoParams();
}
