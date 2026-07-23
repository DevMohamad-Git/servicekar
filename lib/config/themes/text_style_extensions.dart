part of 'app_themes.dart';

/// `TextStyle` factory + helpers that every widget in ServiceKar
/// should reach for instead of calling the [TextStyle] constructor
/// directly.
///
/// Mirrors `lalafen/lib/config/themes/text_style_extensions.dart`
/// 1:1 with two ServiceKar-specific tweaks:
///
///   * `color` defaults to [kTextPrimaryColor] (was a generic
///     grey in Lalafen's prototype).
///   * `height` defaults to 1.4 instead of Lalafen's 1.8 — Lalafen
///     is a lullaby reading app where ultra-loose line-height is
///     kid-friendly; ServiceKar is a data-dense field tool for
///     professionals, where looser spacing hurts glance density.
///
/// Always name the size from the [font_sizes] constants —
/// `kTextSizeTitleLarge`, `kTextSizeBodyMedium`, etc. — never pass
/// raw doubles; otherwise the typographic scale gets fragmented.
extension TextStyleExtensions on TextStyle {
  /// Build a fully-configured [TextStyle] in one call.
  ///
  /// Plugins a single token (`color`) so brand text remains on
  /// the typographic scale. Pass widgets `Text(...,
  /// style: TextStyleExtensions.create(fontSize: kTextSizeBodyLarge))`
  /// rather than `TextStyle(fontSize: 18)`.
  static TextStyle create({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color color = kTextPrimaryColor,
    double height = 1.4,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  /// The "vanilla" text style for screens where no special size
  /// is requested. Used by `Scaffold` body / dialog confirmations.
  static TextStyle get base => const TextStyle(
        fontSize: kTextSizeBodySmall,
        fontWeight: FontWeight.w500,
        color: kTextPrimaryColor,
        height: 1.4,
      );

  /// Override individual style attributes while inheriting the
  /// project's defaults from [base]. `widget.text.withDefaults`
  /// is the idiomatic way to "flip colour to secondary" without
  /// restating every other invisible attribute.
  TextStyle withDefaults({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
      color: color ?? kTextPrimaryColor,
      height: height ?? 1.4,
    );
  }
}
