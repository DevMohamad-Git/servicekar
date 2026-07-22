/// Abstract environment configuration base. Future environments
/// (e.g. `EnvProd`) should extend this and override the relevant
/// getters. Today only [EnvDev] exists; the indirection is kept so
/// we can swap behaviour per build flavour without touching the
/// router code.
abstract class Env {
  /// When `true`, navigation to the customer flow is short-circuited
  /// to a placeholder by the inline redirect guard defined in
  /// `lib/app/router.dart`. Intended as a dev-only feature flag while
  /// the customer feature is still being built out.
  bool get disableCustomerFlow;
}
