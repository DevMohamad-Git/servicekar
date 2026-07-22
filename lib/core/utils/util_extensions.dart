import 'package:flutter/material.dart';

/// Lightweight [BuildContext] extensions. Mirrors
/// `lalafen/lib/core/utils/util_extensions.dart` but kept dependency-free
/// (no `responsive_framework`, no Persian digit conversion) so Servicar
/// compiles without extra packages.
extension ContextUtilsEX on BuildContext {
  /// Quick read of the ambient [ThemeData]. Equivalent to
  /// `Theme.of(this)` but reads better at call sites that already use
  /// `context` as a fluent receiver.
  ThemeData get theme => Theme.of(this);

  /// Currently focused [FocusScopeNode] — used by AppHelper.closeSoftKeyboard.
  FocusScopeNode get focusScope => FocusScope.of(this);

  /// Width of the device multiplied by [factor], floored to a whole
  /// pixel — handy when laying things out as a fraction of the screen.
  double deviceWidthFactor(double factor) {
    return (MediaQuery.sizeOf(this).width * factor).floorToDouble();
  }

  /// Height of the device multiplied by [factor], floored to a whole
  /// pixel — see [deviceWidthFactor].
  double deviceHeightFactor(double factor) {
    return (MediaQuery.sizeOf(this).height * factor).floorToDouble();
  }
}
