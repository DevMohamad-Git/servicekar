import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/utils/jalali_date.dart';
import '../../../features/customer/domain/entities/payment_entity.dart';
import '../../customer/widgets/customer_account_summary_widget.dart';
import '../../customer/widgets/customer_page_header.dart';
import '../../service/logic/service_entry_state.dart';
import '../../service/widgets/customer_selection_section.dart';
import '../../shared/widgets/jalali_date_picker.dart';
import '../logic/payment_entry_state.dart';
import '../widgets/payment_entry_submit_bar.dart';

/// UI-first payment-entry page with local form state.
///
/// Mirrors the service-entry page architecture: submission is a
/// simulated delay + toast (no repository / use case wiring yet), the
/// customer comes from the same shared [mockCustomers] list through the
/// same `CustomerSelectionSection` widget, and the account summary is
/// mock data rendered by the existing `CustomerAccountSummaryWidget`
/// from the customer details page.
///
/// Visual language is identical to `ServiceEntryPage`: soft grey canvas,
/// white field-group cards with hairline borders, gradient icon chips
/// per section, and a bottom-pinned submit bar.
@RoutePage()
class PaymentEntryPage extends StatefulWidget {
  const PaymentEntryPage({super.key});

  @override
  State<PaymentEntryPage> createState() => _PaymentEntryPageState();
}

class _PaymentEntryPageState extends State<PaymentEntryPage> {
  final _formState = PaymentEntryFormState(paymentDate: DateTime.now());
  final _amountController = TextEditingController();
  final _trackingNumberController = TextEditingController();
  final _noteController = TextEditingController();
  final _searchController = TextEditingController();
  PaymentEntrySubmitState _submitState = PaymentEntrySubmitState.idle;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateAmount);
    _trackingNumberController.addListener(_updateTrackingNumber);
  }

  void _updateAmount() {
    final parsed =
        int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    setState(() => _formState.amount = parsed);
  }

  void _updateTrackingNumber() {
    final text = _trackingNumberController.text.trim();
    _formState.trackingNumber = text.isEmpty ? null : text;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _trackingNumberController.dispose();
    _noteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ─── Customer selection ──────────────────────────────────────

  void _selectCustomer(MockCustomer customer) {
    setState(() {
      _formState.selectedCustomer = customer;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _changeCustomer() {
    setState(() => _formState.selectedCustomer = null);
  }

  // ─── Payment method ──────────────────────────────────────────

  void _setMethod(PaymentMethod? method) {
    if (method == null) return;
    setState(() {
      _formState.method = method;
      if (method != PaymentMethod.card) {
        // Card-to-card-only data must not leak into other methods.
        _trackingNumberController.clear();
        _formState.trackingNumber = null;
      }
    });
  }

  // ─── Date picker ─────────────────────────────────────────────

  Future<void> _pickPaymentDate() async {
    final picked = await showJalaliDatePicker(
      context,
      initialDate: _formState.paymentDate ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() => _formState.paymentDate = picked);
    }
  }

  // ─── Submit (mock) ────────────────────────────────────────────

  Future<void> _submit() async {
    _dismissKeyboard();
    setState(() => _submitState = PaymentEntrySubmitState.submitting);

    // Simulate network delay.
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _submitState = PaymentEntrySubmitState.success);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.paymentSubmitted),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kSuccessColor,
        duration: const Duration(seconds: 3),
      ),
    );

    // Reset after a brief showcase of success state.
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _submitState = PaymentEntrySubmitState.idle);
      }
    });
  }

  void _showError() {
    setState(() => _submitState = PaymentEntrySubmitState.error);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.paymentSubmitError),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kErrorColor,
        duration: const Duration(seconds: 3),
      ),
    );
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _submitState = PaymentEntrySubmitState.idle);
      }
    });
  }

  // ─── Layout helpers ──────────────────────────────────────────

  String _formatDisplayDate(DateTime? dt) {
    if (dt == null) return '';
    return toJalali(dt).format();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final isSubmitting = _submitState == PaymentEntrySubmitState.submitting;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: CustomerPageHeader(
        title: l10n.paymentEntry,
        subtitle: l10n.paymentEntrySubtitle,
        titleFontWeight: FontWeight.w700,
        onBack: () => context.router.maybePop(),
      ),
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _dismissKeyboard(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: _FormContent(
                  formState: _formState,
                  amountController: _amountController,
                  trackingNumberController: _trackingNumberController,
                  noteController: _noteController,
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  formatDisplayDate: _formatDisplayDate,
                  onSelectCustomer: _selectCustomer,
                  onChangeCustomer: _changeCustomer,
                  onSearchChanged: (q) => setState(() => _searchQuery = q),
                  onMethodChanged: _setMethod,
                  onPickPaymentDate: _pickPaymentDate,
                ),
              ),
            ),
            PaymentEntrySubmitBar(
              canSubmit: _formState.canSubmit,
              isSubmitting: isSubmitting,
              submitState: _submitState,
              onSubmit: _submit,
              onRetry: _showError,
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable form body that hosts every field section.
///
/// Split into its own private widget to keep [PaymentEntryPage.build]
/// readable and to isolate rebuilds of the form content from the
/// header / submit bar — the same split used by `ServiceEntryPage`.
class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.formState,
    required this.amountController,
    required this.trackingNumberController,
    required this.noteController,
    required this.searchController,
    required this.searchQuery,
    required this.formatDisplayDate,
    required this.onSelectCustomer,
    required this.onChangeCustomer,
    required this.onSearchChanged,
    required this.onMethodChanged,
    required this.onPickPaymentDate,
  });

  final PaymentEntryFormState formState;
  final TextEditingController amountController;
  final TextEditingController trackingNumberController;
  final TextEditingController noteController;
  final TextEditingController searchController;
  final String searchQuery;
  final String Function(DateTime?) formatDisplayDate;
  final ValueChanged<MockCustomer> onSelectCustomer;
  final VoidCallback onChangeCustomer;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<PaymentMethod?> onMethodChanged;
  final VoidCallback onPickPaymentDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── 1. Customer selection (shared with service entry) ──
        CustomerSelectionSection(
          selectedCustomer: formState.selectedCustomer,
          searchQuery: searchQuery,
          searchController: searchController,
          onSelectCustomer: onSelectCustomer,
          onChangeCustomer: onChangeCustomer,
          onSearchChanged: onSearchChanged,
        ),

        // ─── 2. Account summary (after selection) ───────────────
        if (formState.selectedCustomer != null) ...[
          const SizedBox(height: 14),
          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CardHeader(
                  icon: Icons.account_balance_outlined,
                  title: l10n.accountSummary,
                ),
                const SizedBox(height: 6),
                Builder(
                  builder: (context) {
                    final balance = mockBalanceFor(
                      formState.selectedCustomer!,
                    );
                    return CustomerAccountSummaryWidget(
                      status: balance.status,
                      amount: balance.amount,
                      lastUpdated: balance.lastUpdated,
                      // The host _FormCard already pads its content;
                      // a second inset would leave the summary swimming
                      // in dead space.
                      outerPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),

        // ─── 3. Payment amount ──────────────────────────────────
        _FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                icon: Icons.payments_outlined,
                title: l10n.paymentAmount,
              ),
              const SizedBox(height: 14),
              _NumberField(
                controller: amountController,
                label: l10n.paymentAmount,
                prefixIcon: Icons.payments_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ─── 4. Payment method (+ optional tracking number) ─────
        _FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                icon: Icons.swap_horiz_rounded,
                title: l10n.paymentMethod,
              ),
              const SizedBox(height: 14),
              SegmentedButton<PaymentMethod>(
                segments: [
                  ButtonSegment<PaymentMethod>(
                    value: PaymentMethod.cash,
                    label: Text(l10n.paymentMethodCash),
                  ),
                  ButtonSegment<PaymentMethod>(
                    value: PaymentMethod.card,
                    label: Text(l10n.paymentMethodCard),
                  ),
                ],
                selected: {formState.method},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    onMethodChanged(selection.first),
                style: _segmentedStyle(Theme.of(context).colorScheme),
              ),

              // Tracking number appears only for card-to-card; driven
              // entirely by the form-state method field.
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: formState.method == PaymentMethod.card
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: TextFormField(
                          controller: trackingNumberController,
                          keyboardType: TextInputType.number,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            labelText: l10n.trackingNumber,
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                            hintText: l10n.trackingNumberHint,
                            hintStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: kGrey3Color),
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ─── 5. Payment date ────────────────────────────────────
        _FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                icon: Icons.calendar_month_outlined,
                title: l10n.paymentDate,
              ),
              const SizedBox(height: 14),
              _DateTile(
                label: formatDisplayDate(formState.paymentDate),
                icon: Icons.calendar_month_outlined,
                onTap: onPickPaymentDate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ─── 6. Note ────────────────────────────────────────────
        _FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(icon: Icons.notes_outlined, title: l10n.paymentNote),
              const SizedBox(height: 14),
              TextFormField(
                controller: noteController,
                maxLines: 3,
                minLines: 3,
                textDirection: TextDirection.rtl,
                onChanged: (value) => formState.note = value,
                decoration: InputDecoration(
                  hintText: l10n.paymentNoteHint,
                  alignLabelWithHint: true,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kGrey3Color,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ─── Bottom breathing room under the submit bar ─────────
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Shared form primitives ───────────────────────────────────

/// Field-group card floating on the grey canvas — same surface recipe
/// as `_FormCard` in `ServiceEntryPage` (hairline border + ultra-soft
/// shadow, 16 dp radius).
class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kGrey4Color.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Card header: icon chip + subtitle-style title — same typography
/// convention (`titleSmall.w600`) as `_CardHeader` in
/// `ServiceEntryPage`.
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: scheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: kTextPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

ButtonStyle _segmentedStyle(ColorScheme scheme) {
  return ButtonStyle(
    visualDensity: VisualDensity.compact,
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    ),
    side: WidgetStatePropertyAll(BorderSide(color: kGrey4Color)),
    shape: const WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? scheme.primary
          : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.selected) ? Colors.white : kGrey2Color,
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}

/// Numeric input field with live comma formatting — verbatim behaviour
/// of `_NumberField` in `ServiceEntryPage` (digits-only keyboard,
/// cursor-preserving comma insertion).
class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  bool _isFormatting = false;
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasValue = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // Reveal the "تومان" suffix only while an amount is entered.
    final hasValue = widget.controller.text.isNotEmpty;
    if (hasValue != _hasValue) {
      setState(() => _hasValue = hasValue);
    }

    if (_isFormatting) return;
    final ctrl = widget.controller;
    final oldText = ctrl.text;
    final oldCursor = ctrl.selection.baseOffset;

    // Strip commas and non-digit characters.
    final raw = oldText.replaceAll(RegExp(r'[^\d]'), '');
    if (raw.isEmpty) {
      if (oldText.isNotEmpty) {
        _isFormatting = true;
        ctrl.text = '';
        _isFormatting = false;
      }
      return;
    }

    final parsed = int.tryParse(raw) ?? 0;
    final formatted = _formatWithCommas(parsed);

    if (formatted == oldText) return;

    // Preserve cursor at the same logical digit position.
    final newCursor = _recomputeCursor(oldText, oldCursor, formatted);

    _isFormatting = true;
    ctrl.text = formatted;
    ctrl.selection = TextSelection.collapsed(
      offset: newCursor.clamp(0, formatted.length),
    );
    _isFormatting = false;
  }

  /// Maps the old cursor position into the new formatted text, preserving the
  /// logical digit position (commas don't count as cursor positions).
  int _recomputeCursor(String oldText, int oldCursor, String newText) {
    if (oldCursor <= 0 || oldCursor > oldText.length) return newText.length;

    // Number of commas before oldCursor in the old text.
    final oldCommasBefore =
        ','.allMatches(oldText.substring(0, oldCursor)).length;
    final digitIndex = oldCursor - oldCommasBefore;

    // Walk the new text until we've seen digitIndex digits.
    var digitsSeen = 0;
    for (var i = 0; i < newText.length; i++) {
      if (newText[i] != ',') digitsSeen++;
      if (digitsSeen >= digitIndex) return i + 1;
    }
    return newText.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.rtl,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: kTextPrimaryColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(widget.prefixIcon, size: 16, color: kGrey3Color),
        // Currency suffix at the text's end side (left in RTL) — shown
        // only while an amount is entered so the empty field stays clean.
        suffixText: _hasValue ? context.l10n.toman : null,
        suffixStyle: theme.textTheme.labelLarge?.copyWith(
          color: kGrey2Color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Tappable tile that displays a formatted date and opens the picker —
/// same look as `_DateTile` in `ServiceEntryPage`.
class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasValue = label.isNotEmpty;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: kGrey4Color.withValues(alpha: 0.9)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasValue ? label : '...',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: hasValue
                        ? kTextPrimaryColor
                        : scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_left,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formats an integer with comma-separated thousands (e.g. 250000 → 250,000).
String _formatWithCommas(int value) {
  final chars = value.toString().split('');
  final buffer = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && (chars.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(chars[i]);
  }
  return buffer.toString();
}
