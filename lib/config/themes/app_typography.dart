part of 'app_themes.dart';

// ─── Typography scale (private to this file) ────────────────────
// ServiceKar's "Large and Readable User Interface" requirement
// (target users: field-service technicians in basements / boiler
// rooms / dim customer sites) drives sizes ~2sp above M3
// defaults across the 13 Material 3 roles. One named constant
// per role, so a redesign edits one identifier per role rather
// than scanning a 90-line copyWith chain for raw numbers.
//
// We deliberately keep this scale *separate from* `font_sizes.dart`:
//   * `font_sizes.dart` exposes tier-named constants
//     (`kTextSizeTitleSmall`, etc.) for one-off widget sites
//     that use `TextStyleExtensions.create(fontSize: ...)` or
//     `TextStyleExtensions.base`. Those tiers cover 9 roles.
//   * This file's scale covers all 13 M3 roles — display and
//     headline tiers not represented in `font_sizes.dart`, plus
//     title / body / label twins in a labelled pattern. Future
//     widget-side tweaks should reach into this file via
//     `Theme.of(context).textTheme.X` rather than re-introducing
//     raw numbers in the call site.
const double _kDisplayLargeSize = 64.0;
const double _kDisplayMediumSize = 52.0;
const double _kDisplaySmallSize = 44.0;
const double _kHeadlineLargeSize = 36.0;
const double _kHeadlineMediumSize = 32.0;
const double _kHeadlineSmallSize = 28.0;
const double _kTitleLargeSize = 24.0;
const double _kTitleMediumSize = 18.0;
const double _kTitleSmallSize = 16.0;
const double _kBodyLargeSize = 17.0;
const double _kBodyMediumSize = 15.0;
const double _kBodySmallSize = 13.0;
const double _kLabelLargeSize = 16.0;
const double _kLabelMediumSize = 14.0;
const double _kLabelSmallSize = 12.0;

// Per-role font weights — pinned at the role level so consumers
// don't have to override `Text` widgets individually.
const FontWeight _kDisplayWeight = FontWeight.w700;
const FontWeight _kHeadlineLargeWeight = FontWeight.w700;
const FontWeight _kHeadlineMediumWeight = FontWeight.w700;
const FontWeight _kHeadlineSmallWeight = FontWeight.w600;
const FontWeight _kTitleWeight = FontWeight.w600;
const FontWeight _kBodyWeight = FontWeight.w400;
const FontWeight _kLabelWeight = FontWeight.w600;

// Per-role line height — tighter for display/headline, looser
// for body and label where glance density matters more.
const double _kDisplayTightHeight = 1.10;
const double _kDisplaySlightLooseHeight = 1.15;
const double _kHeadlineHeight = 1.20;
const double _kTitleLargeHeight = 1.25;
const double _kTitleCompactHeight = 1.30;
const double _kBodyLooseHeight = 1.40;

/// Builds the Material 3 [TextTheme] for ServiceKar's presentation
/// layer.
///
/// Uses ServiceKar-specific 13-role scale declared as private
/// named constants at the top of this file, so widgets reading
/// `Theme.of(context).textTheme.bodyLarge` get readable body
/// text out of the box. The shape is preserved one-to-one with
/// M3 defaults — only sizes / weights / line-heights are tuned.
///
/// Why we wire this even though Lalafen wires it NOT through the
/// mixin — ServiceKar's README explicitly demands "Large and
/// Readable User Interface" for field-service technicians working
/// in basements, boiler rooms, and dim customer sites. Keeping
/// the typography theme wired into [ThemeData.textTheme] means
/// every widget consuming [Theme.of(context).textTheme.X] gets
/// the elevated scale automatically, with no per-widget call-site
/// migration needed.
///
/// Pass [base] the result of [ThemeData.light]'s `textTheme`
/// (e.g. inside the [AppThemes.light] factory). This function
/// only mutates role attributes, never the family.
TextTheme buildAppTextTheme(TextTheme base) => base.copyWith(
      // ─── Display ─────────────────────────────────────────────────
      displayLarge: base.displayLarge?.copyWith(
        fontSize: _kDisplayLargeSize,
        fontWeight: _kDisplayWeight,
        height: _kDisplayTightHeight,
      ),
      displayMedium: base.displayMedium?.copyWith(
        fontSize: _kDisplayMediumSize,
        fontWeight: _kDisplayWeight,
        height: _kDisplaySlightLooseHeight,
      ),
      displaySmall: base.displaySmall?.copyWith(
        fontSize: _kDisplaySmallSize,
        fontWeight: _kDisplayWeight,
        height: _kDisplaySlightLooseHeight,
      ),
      // ─── Headline ────────────────────────────────────────────────
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: _kHeadlineLargeSize,
        fontWeight: _kHeadlineLargeWeight,
        height: _kHeadlineHeight,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: _kHeadlineMediumSize,
        fontWeight: _kHeadlineMediumWeight,
        height: _kHeadlineHeight,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: _kHeadlineSmallSize,
        fontWeight: _kHeadlineSmallWeight,
        height: _kTitleLargeHeight,
      ),
      // ─── Title ───────────────────────────────────────────────────
      titleLarge: base.titleLarge?.copyWith(
        fontSize: _kTitleLargeSize,
        fontWeight: _kTitleWeight,
        height: _kTitleLargeHeight,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: _kTitleMediumSize,
        fontWeight: _kTitleWeight,
        height: _kTitleCompactHeight,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: _kTitleSmallSize,
        fontWeight: _kTitleWeight,
        height: _kTitleCompactHeight,
      ),
      // ─── Body ────────────────────────────────────────────────────
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: _kBodyLargeSize,
        fontWeight: _kBodyWeight,
        height: _kBodyLooseHeight,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: _kBodyMediumSize,
        fontWeight: _kBodyWeight,
        height: _kBodyLooseHeight,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: _kBodySmallSize,
        fontWeight: _kBodyWeight,
        height: _kBodyLooseHeight,
      ),
      // ─── Label (chips, buttons, balance tag) ─────────────────────
      labelLarge: base.labelLarge?.copyWith(
        fontSize: _kLabelLargeSize,
        fontWeight: _kLabelWeight,
        height: _kTitleCompactHeight,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: _kLabelMediumSize,
        fontWeight: _kLabelWeight,
        height: _kTitleCompactHeight,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: _kLabelSmallSize,
        fontWeight: _kLabelWeight,
        height: _kTitleCompactHeight,
      ),
    );
