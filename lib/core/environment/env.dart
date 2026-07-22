/// Abstract environment configuration base. Concrete environments
/// (e.g. [EnvDev]) extend this and override the relevant getters.
///
/// In the new layout the active environment is exposed to the rest
/// of the app via the Riverpod `envProvider` defined in
/// `lib/injection/global_providers.dart`. Routes and global helpers
/// (AppHelper, AppRouter) read it from there. Process-wide
/// `appEnv` is kept as a fallback for migration scenarios where a
/// non-Riverpod caller still needs a synchronous handle.
abstract class Env {
  const Env();

  /// When `true`, navigation to the customer flow can be
  /// short-circuited by a redirect guard. Production environments
  /// override to `false`.
  bool get disableCustomerFlow;
}
