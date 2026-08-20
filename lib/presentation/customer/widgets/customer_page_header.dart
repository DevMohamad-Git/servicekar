import 'package:flutter/material.dart';

import '../../../config/themes/app_themes.dart';

/// Side length of the tappable back slot in
/// [CustomerPageHeader]. Tracks the larger 64dp toolbar height so the
/// IconButton reads as a generous touch target without crowding the
/// centered title.
const double _kHeaderSlotSize = 52.0;

/// Size of the title's leading icon (only the list page uses it).
const double _kTitleIconSize = 28.0;

/// Size of the back-arrow icon, slightly larger than the Material
/// default for legibility in the wider 64dp band.
const double _kBackIconSize = 26.0;

/// Fallback top safe-area inset used while the State has not yet
/// measured [MediaQueryData.padding.top]. Modern phones report top
/// insets from 0dp (no notch / status bar) to ~44dp (Dynamic Island /
/// camera cutout) — picking a generous 30dp default keeps Scaffold
/// from reserving too LITTLE space on weird viewports while we wait
/// for the real value.
const double _kFallbackTopInset = 30.0;

/// Shared minimal header for every customer page (list, create, profile,
/// edit).
///
/// Renders a flat, white header with no shadow or divider: a back affordance
/// pinned to the LEFT edge, a centered title (optionally with a leading icon
/// and a one-line subtitle, as on the customer-list page), and
/// caller-supplied actions pinned to the RIGHT edge. The toolbar height
/// follows the app theme's `kAppbarHeight` (one step above the Material
/// default of 56dp so the band reads as a confident title strip).
///
/// ─── Edge-to-edge architecture ────────────────────────────────────
/// The Material surface is NOT wrapped in a top [SafeArea]: the white
/// background must flow from the physical top edge of the window down
/// through the toolbar so the OS status-bar strip is the same white as
/// the header (with `Colors.transparent` status bar applied globally in
/// `main.dart`, the SystemUiOverlayStyle shows dark status-bar icons
/// against the white surface). Only the inner toolbar ROW is wrapped in
/// `SafeArea(bottom: false, top: true)` so the back button / title /
/// actions are pushed below the notch / status bar items without
/// wasting paint on a second padded band of surface above us.
///
/// ─── Preferred size ──────────────────────────────────────────────
/// The widget runs as a [PreferredSizeWidget] so [Scaffold] can reserve
/// the correct vertical slice for it. We use the canonical Flutter
/// pattern (mirrored by `AppBar` itself): the State reads
/// [MediaQueryData.padding] in [State.didChangeDependencies], then
/// mutates a `Size` field on the widget so the next read of
/// `widget.preferredSize` returns the runtime measured value. Until that
/// post-mount update fires we report a generous fallback so Scaffold can
/// lay out without an exception; on the very next frame the real size
/// (top safe-area inset + 64dp prominent toolbar) takes over and the
/// body re-positions flush under the rendered header.
// Flutter's @immutable lint flags the mutable `_preferredSize` field
// even though it is mutated exclusively by the State for layout hints
// (matching `package:flutter/src/material/app_bar.dart`'s pattern).
// ignore: must_be_immutable
class CustomerPageHeader extends StatefulWidget
    implements PreferredSizeWidget {
  CustomerPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.titleIcon,
    this.onBack,
    this.actions = const [],
  });

  /// Primary title, centered in the header.
  final String title;

  /// Optional second line shown under [title] (only the list page uses it).
  final String? subtitle;

  /// Optional icon rendered just before [title] (only the list page uses it).
  final IconData? titleIcon;

  /// When non-null, a back button is shown on the left edge.
  final VoidCallback? onBack;

  /// Right-edge actions, e.g. the create-page save button or the
  /// profile-page overflow menu.
  final List<Widget> actions;

  /// Size hint Scaffold uses to reserve the AppBar slot. We carry it as
  /// a mutable `Size` field so the State can overwrite it with the
  /// runtime top-safe-area value on the first frame after mount, and
  /// any time the user's window / rotation changes that padding.
  ///
  /// Material's `AppBar` uses the same field-mutation pattern — see
  /// `package:flutter/src/material/app_bar.dart` (`AppBar._preferredSize`).
  // ignore: must_be_immutable
  Size _preferredSize = const Size.fromHeight(
    kAppbarHeight + _kFallbackTopInset,
  );

  @override
  Size get preferredSize => _preferredSize;

  @override
  State<CustomerPageHeader> createState() => _CustomerPageHeaderState();
}

/// State that re-measures the status-bar inset on every dependency
/// change (mount, rotation, parent `MediaQuery` swap) and pushes the
/// new height into the widget's `preferredSize` so Scaffold's next
/// layout pass reserves a slot as tall as the rendered header.
class _CustomerPageHeaderState extends State<CustomerPageHeader> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final topInset = MediaQuery.of(context).padding.top;
    final next = Size.fromHeight(topInset + kAppbarHeight);
    if (next.height != widget._preferredSize.height) {
      // Field-mutation pattern is the canonical Flutter way to expose a
      // MediaQuery-derived preferredSize from a PreferredSizeWidget;
      // see the class-level docstring on `CustomerPageHeader` for the
      // source mirror. Updating `_preferredSize` here triggers
      // Scaffold's AppBar-layout recomputation on the next frame so
      // the body's top edge stays flush with the bottom of the
      // rendered header even when rotation or split-screen changes
      // the OS inset.
      setState(() => widget._preferredSize = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The header sits one size above the page's standard `titleLarge`
    // so the band reads as a strong title strip — Material's 56dp
    // toolbars pair with titleLarge (~22sp); our 64dp "prominent"
    // toolbar bumps to ~28sp to keep visual weight proportional to
    // the wider band.
    final baseTitleSize = theme.textTheme.titleLarge?.fontSize ?? 22.0;
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: kTextPrimaryColor,
      fontWeight: FontWeight.w700,
      fontSize: baseTitleSize + 4,
    );

    // ─── Slot builders ────────────────────────────────────────────
    // The layout is pinned explicitly LTR so the back arrow always sits
    // on the LEFT edge and the caller actions on the RIGHT, independent
    // of the app's RTL text direction. When one side is empty, a
    // symmetric 52dp spacer keeps the centered title optically centered.
    final backSlot = SizedBox(
      width: _kHeaderSlotSize,
      height: _kHeaderSlotSize,
      child: widget.onBack == null
          ? null
          : IconButton(
              tooltip: 'بازگشت',
              onPressed: widget.onBack,
              iconSize: _kBackIconSize,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
    );
    final actionsSlot = widget.actions.isEmpty
        ? const SizedBox(width: _kHeaderSlotSize, height: _kHeaderSlotSize)
        : Row(mainAxisSize: MainAxisSize.min, children: widget.actions);

    // ─── Surface (edge-to-edge) ───────────────────────────────────
    // `Material(color: Colors.white)` is the ROOT of this widget: no
    // SafeArea around it, so the painted white surface extends from
    // y=0 (top of the window) all the way through the toolbar's bottom
    // edge. The OS status bar is drawn transparent by the
    // SystemUiOverlayStyle configured in `main.dart`, so the status
    // bar glyphs appear directly on top of this white surface — one
    // continuous white surface from screen edge to header bottom edge.
    //
    // Inside the Material, a `Column(mainAxisSize: MainAxisSize.min)`
    // wraps the SafeArea+toolbar block. The SafeArea(top: true,
    // bottom: false) is the INNER inset — it pushes the iconic row
    // (back button / title / actions) clear of the status-bar / notch
    // without adding a second blank painted band above it. The
    // SizedBox(height: kAppbarHeight) pins the toolbar to exactly
    // 64dp so the title row's vertical rhythm matches the Material
    // "prominent" toolbar convention (56dp + one step).
    return Material(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: kAppbarHeight,
              child: IconTheme.merge(
                data: const IconThemeData(color: kTextPrimaryColor),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    backSlot,
                    Expanded(
                      child: Center(
                        child: _HeaderTitle(
                          title: widget.title,
                          subtitle: widget.subtitle,
                          titleIcon: widget.titleIcon,
                          titleStyle: titleStyle,
                        ),
                      ),
                    ),
                    actionsSlot,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two-line title used inside [CustomerPageHeader]: an optional icon
/// plus the prominent title, and an optional faint subtitle beneath
/// it.
class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({
    required this.title,
    required this.titleStyle,
    this.subtitle,
    this.titleIcon,
  });

  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final IconData? titleIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleWidget = titleIcon == null
        ? Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: titleStyle,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                titleIcon,
                size: _kTitleIconSize,
                color: kTextPrimaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: titleStyle,
              ),
            ],
          );

    if (subtitle == null) {
      return titleWidget;
    }

    // The subtitle is one step above labelLarge (~18sp) so it sits as
    // an obvious secondary line under the 28sp title without
    // overpowering it (labelLarge alone would feel too tight at
    // 16sp against the now-larger title).
    final baseSubtitleSize = theme.textTheme.labelLarge?.fontSize ?? 14.0;
    final subtitleStyle = theme.textTheme.labelLarge?.copyWith(
      color: kGrey3Color,
      fontWeight: FontWeight.w500,
      fontSize: baseSubtitleSize + 2,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        titleWidget,
        const SizedBox(height: 2),
        Text(
          subtitle!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: subtitleStyle,
        ),
      ],
    );
  }
}
