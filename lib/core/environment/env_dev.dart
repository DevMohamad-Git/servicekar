import 'env.dart';

/// Dev-environment configuration. Currently flips the customer flow
/// off so any redirect guard could divert `/customers`. Production
/// environments should override `disableCustomerFlow` to return
/// `false`.
class EnvDev extends Env {
  const EnvDev();

  @override
  bool get disableCustomerFlow => false;
}

/// Process-wide dev environment instance. Held at top-level so
/// transitional callers can read flags without yet routing through
/// `envProvider`. Move all callers behind the Riverpod provider as
/// they are touched in subsequent tasks.
final Env appEnv = EnvDev();
