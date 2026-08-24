import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/l10n/arb/app_localizations.dart';
import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../core/utils/jalali_date.dart';
import '../../shared/widgets/jalali_date_picker.dart';
import '../../customer/widgets/customer_page_header.dart';
import '../logic/service_entry_state.dart';
import '../services/service_photo_picker.dart';
import '../widgets/customer_selection_section.dart';
import '../widgets/service_photos_section.dart';
import '../widgets/service_entry_submit_bar.dart';

/// UI-first service-entry page with local form state and real photo picking.
///
/// Submission is still a simulated delay + toast (no database, repository,
/// or use case yet), but service photos come from the real camera/gallery
/// through [ServicePhotoPicker] — permission requests and plugin failures
/// are surfaced as an error snackbar.
///
/// Visual language: modern-minimal grouped form. A soft grey canvas hosts
/// field-group cards (hairline border + ultra-soft shadow) in the
/// Stripe / Linear tradition, each washed with a subtle white→accent
/// diagonal gradient and anchored by a gradient icon chip so sections
/// are colour-coded at a glance. Card headers are bold and prominent;
/// field labels and hints are smaller and muted.
@RoutePage()
class ServiceEntryPage extends StatefulWidget {
  const ServiceEntryPage({super.key, this.photoPicker});

  /// Injectable picker boundary used by tests; production uses image_picker.
  final ServicePhotoPicker? photoPicker;

  @override
  State<ServiceEntryPage> createState() => _ServiceEntryPageState();
}

class _ServiceEntryPageState extends State<ServiceEntryPage> {
  late final ServicePhotoPicker _photoPicker =
      widget.photoPicker ?? ServicePhotoPicker();
  final _formState = ServiceEntryFormState(serviceDate: DateTime.now());
  final _descriptionController = TextEditingController();
  final _serviceFeeController = TextEditingController();
  final _partsFeeController = TextEditingController();
  final _searchController = TextEditingController();
  ServiceEntrySubmitState _submitState = ServiceEntrySubmitState.idle;
  String _searchQuery = '';
  int _totalFee = 0;

  @override
  void initState() {
    super.initState();
    _serviceFeeController.addListener(_updateTotalFee);
    _partsFeeController.addListener(_updateTotalFee);
  }

  void _updateTotalFee() {
    final serviceFee =
        int.tryParse(_serviceFeeController.text.replaceAll(',', '')) ?? 0;
    final partsFee =
        int.tryParse(_partsFeeController.text.replaceAll(',', '')) ?? 0;
    setState(() {
      _totalFee = serviceFee + partsFee;
      // Keep form-state fee fields in sync so canSubmit reacts live.
      _formState.serviceFee = _serviceFeeController.text;
      _formState.partsFee = _partsFeeController.text;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _serviceFeeController.dispose();
    _partsFeeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // ─── Date picker helpers ──────────────────────────────────────

  Future<void> _pickServiceDate() async {
    final picked = await showJalaliDatePicker(
      context,
      initialDate: _formState.serviceDate ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() => _formState.serviceDate = picked);
    }
  }

  Future<void> _pickNextServiceDate() async {
    final now = DateTime.now();
    final picked = await showJalaliDatePicker(
      context,
      initialDate:
          _formState.nextServiceDate ?? now.add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _formState.nextServiceDate = picked);
    }
  }

  // ─── Photo picking (camera / gallery) ────────────────────────

  Future<void> _openPhotoSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  sheetContext.l10n.choosePhotoSource,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _SheetAction(
                icon: Icons.camera_alt_outlined,
                label: sheetContext.l10n.camera,
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              _SheetAction(
                icon: Icons.photo_library_outlined,
                label: sheetContext.l10n.gallery,
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || source == null) return;
    await _addPhotoFromSource(source);
  }

  Future<void> _addPhotoFromSource(ImageSource source) async {
    final result = await _photoPicker.pick(source);
    if (!mounted) return;

    if (result.isSelected && result.file != null) {
      setState(() {
        _formState.photos = List<MockServicePhoto>.from(_formState.photos)
          ..add(
            MockServicePhoto(
              id: 'photo-${DateTime.now().millisecondsSinceEpoch}',
              path: result.file!.path,
            ),
          );
      });
    } else if (result.isFailed) {
      // Permission denied or a plugin failure — tell the user instead of
      // silently adding a placeholder.
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.servicePhotoError),
          behavior: SnackBarBehavior.floating,
          backgroundColor: kErrorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    // Cancellation intentionally leaves the current photos untouched.
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

  void _setServiceType(ServiceType? type) {
    if (type != null) setState(() => _formState.serviceType = type);
  }

  // ─── Submit (mock) ────────────────────────────────────────────

  Future<void> _submit() async {
    _dismissKeyboard();
    setState(() => _submitState = ServiceEntrySubmitState.submitting);

    // Simulate network delay.
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _submitState = ServiceEntrySubmitState.success);

    // Use ScaffoldMessenger to show success toast (no Riverpod needed).
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.serviceSubmitted),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kSuccessColor,
        duration: const Duration(seconds: 3),
      ),
    );

    // Reset after a brief showcase of success state.
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _submitState = ServiceEntrySubmitState.idle);
      }
    });
  }

  void _showError() {
    setState(() => _submitState = ServiceEntrySubmitState.error);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.serviceSubmitError),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kErrorColor,
        duration: const Duration(seconds: 3),
      ),
    );
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _submitState = ServiceEntrySubmitState.idle);
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

    final isSubmitting = _submitState == ServiceEntrySubmitState.submitting;

    return Scaffold(
      // Soft grey canvas so the white field-group cards float on it.
      backgroundColor: kBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: CustomerPageHeader(
        title: l10n.serviceEntry,
        subtitle: l10n.serviceEntrySubtitle,
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
                  descriptionController: _descriptionController,
                  serviceFeeController: _serviceFeeController,
                  partsFeeController: _partsFeeController,
                  totalFee: _totalFee,
                  searchController: _searchController,
                  searchQuery: _searchQuery,
                  formatDisplayDate: _formatDisplayDate,
                  onSelectCustomer: _selectCustomer,
                  onChangeCustomer: _changeCustomer,
                  onSearchChanged: (q) => setState(() => _searchQuery = q),
                  onPickServiceDate: _pickServiceDate,
                  onPickNextServiceDate: _pickNextServiceDate,
                  onOpenPhotoSourcePicker: _openPhotoSourcePicker,
                  onReminderToggle: () => setState(
                    () => _formState.reminderEnabled =
                        !_formState.reminderEnabled,
                  ),
                  onServiceTypeChanged: _setServiceType,
                ),
              ),
            ),
            ServiceEntrySubmitBar(
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
/// Split into its own private widget to keep [ServiceEntryPage.build]
/// readable and to isolate rebuilds of the form content from the
/// header / submit bar.
class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.formState,
    required this.descriptionController,
    required this.serviceFeeController,
    required this.partsFeeController,
    required this.totalFee,
    required this.searchController,
    required this.searchQuery,
    required this.formatDisplayDate,
    required this.onSelectCustomer,
    required this.onChangeCustomer,
    required this.onSearchChanged,
    required this.onPickServiceDate,
    required this.onPickNextServiceDate,
    required this.onOpenPhotoSourcePicker,
    required this.onReminderToggle,
    required this.onServiceTypeChanged,
  });

  final ServiceEntryFormState formState;
  final TextEditingController descriptionController;
  final TextEditingController serviceFeeController;
  final TextEditingController partsFeeController;
  final int totalFee;
  final TextEditingController searchController;
  final String searchQuery;
  final String Function(DateTime?) formatDisplayDate;
  final ValueChanged<MockCustomer> onSelectCustomer;
  final VoidCallback onChangeCustomer;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onPickServiceDate;
  final VoidCallback onPickNextServiceDate;
  final VoidCallback onOpenPhotoSourcePicker;
  final VoidCallback onReminderToggle;
  final ValueChanged<ServiceType?> onServiceTypeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── 1. Customer selection ──────────────────────────────
        CustomerSelectionSection(
          selectedCustomer: formState.selectedCustomer,
          searchQuery: searchQuery,
          searchController: searchController,
          onSelectCustomer: onSelectCustomer,
          onChangeCustomer: onChangeCustomer,
          onSearchChanged: onSearchChanged,
        ),
        const SizedBox(height: 14),

        // ─── 2. Service details (type + description) ────────────
        _FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                icon: Icons.build_outlined,
                title: l10n.serviceDetails,
              ),
              const SizedBox(height: 14),
              _FieldLabel(label: l10n.serviceType),
              const SizedBox(height: 8),
              SegmentedButton<ServiceType>(
                segments: [
                  for (final type in ServiceType.values)
                    ButtonSegment<ServiceType>(
                      value: type,
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(_serviceTypeLabel(l10n, type)),
                      ),
                    ),
                ],
                selected: {formState.serviceType ?? ServiceType.periodic},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    onServiceTypeChanged(selection.first),
                style: _segmentedStyle(Theme.of(context).colorScheme),
              ),
              const SizedBox(height: 16),
              _FieldLabel(label: l10n.serviceDescription),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                minLines: 3,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: l10n.serviceDescriptionHint,
                  alignLabelWithHint: true,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kGrey3Color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ─── 3. Costs ───────────────────────────────────────────
        _FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                icon: Icons.credit_card_outlined,
                title: l10n.serviceCosts,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _NumberField(
                      controller: serviceFeeController,
                      label: l10n.serviceFee,
                      prefixIcon: Icons.build_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NumberField(
                      controller: partsFeeController,
                      label: l10n.partsFee,
                      prefixIcon: Icons.handyman_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _TotalCostField(label: l10n.totalCost, total: totalFee),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ─── 4. Schedule (service date + reminder) ──────────────
        _FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                icon: Icons.calendar_month_outlined,
                title: l10n.serviceDate,
              ),
              const SizedBox(height: 14),
              _DateTile(
                label: formatDisplayDate(formState.serviceDate),
                icon: Icons.calendar_month_outlined,
                onTap: onPickServiceDate,
              ),
              const SizedBox(height: 12),
              _ReminderSection(
                enabled: formState.reminderEnabled,
                nextDate: formState.nextServiceDate,
                formatDisplayDate: formatDisplayDate,
                onToggle: onReminderToggle,
                onPickDate: onPickNextServiceDate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ─── 5. Service photos ──────────────────────────────────
        _FormCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CardHeader(
                icon: Icons.image_outlined,
                title: l10n.servicePhotos,
              ),
              const SizedBox(height: 14),
              ServicePhotosSection(
                photos: formState.photos,
                onAddPhoto: onOpenPhotoSourcePicker,
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

/// Field-group card floating on the grey canvas.
///
/// Hairline border + ultra-soft shadow gives the card physical presence
/// without the heavy elevation of legacy Material cards. When [accent] is
/// set, the white surface washes into a soft accent tint along the reading
/// direction and the border picks up the same hue, colour-coding the
/// section while keeping inputs (grey-filled) perfectly readable.
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

/// Card header: icon chip + subtitle-style title.
///
/// Uses `titleSmall.w600` — the exact typography convention from
/// `_SectionWithSurface` in CreateCustomerPage — so section headers
/// feel uniform across the app.
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

/// Field label inside a form card.
///
/// Uses `labelLarge.onSurfaceVariant.w500` — the exact typography
/// convention from `_CreateField` in CreateCustomerPage — so field
/// labels feel uniform across the app.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

String _serviceTypeLabel(AppLocalizations l10n, ServiceType type) =>
    switch (type) {
      ServiceType.periodic => l10n.serviceTypePeriodic,
      ServiceType.repair => l10n.serviceTypeRepair,
      ServiceType.installation => l10n.serviceTypeInstallation,
    };

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

/// Numeric input field with live comma formatting, tailored for cost entries.
///
/// As the user types, commas are inserted on-the-fly (e.g. 250000 → 250,000).
/// The keyboard is restricted to digits only. Entered amounts render one
/// tier larger and darker than the muted label — the user's own data is the
/// loudest text in the field.
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

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
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
      ),
    );
  }
}

/// Tappable tile that displays a formatted date and opens the picker.
///
/// Flat white surface + hairline border — no tinted fill.
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

/// Reminder toggle row with an animated reveal of the next-service date.
///
/// Kept intentionally minimal: a subtle icon + label row with a compact
/// switch — the visual weight is on the date tile that appears below,
/// not on the chrome around the toggle itself.
class _ReminderSection extends StatelessWidget {
  const _ReminderSection({
    required this.enabled,
    required this.nextDate,
    required this.formatDisplayDate,
    required this.onToggle,
    required this.onPickDate,
  });

  final bool enabled;
  final DateTime? nextDate;
  final String Function(DateTime?) formatDisplayDate;
  final VoidCallback onToggle;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Compact toggle row — icon, subtle label, small switch.
        Row(
          children: [              Icon(
                Icons.notifications_none,
                size: 16,
              color: enabled ? scheme.primary : kGrey3Color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.nextServiceReminder,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: enabled ? kTextPrimaryColor : kGrey3Color,
                ),
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: enabled,
                onChanged: (_) => onToggle(),
                activeTrackColor: scheme.primary.withValues(alpha: 0.4),
                activeThumbColor: scheme.primary,
              ),
            ),
          ],
        ),

        // Next-service-date field — animated in/out with the toggle.
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: enabled
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: _DateTile(
                    label: formatDisplayDate(nextDate),
                    icon: Icons.calendar_month_outlined,
                    onTap: onPickDate,
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
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

/// Read-only display for the total cost (service fee + parts fee).
///
/// Echoes the costs card's teal gradient at a slightly stronger wash so
/// the computed total reads as the card's conclusion; the amount counts
/// up with a short tween whenever the fees change — a micro-interaction
/// borrowed from fintech checkouts.
class _TotalCostField extends StatelessWidget {
  const _TotalCostField({required this.label, required this.total});

  final String label;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kGrey4Color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 20,
            color: scheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: total),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              '${_formatWithCommas(value)} ${context.l10n.toman}',
              textDirection: TextDirection.rtl,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One tappable row inside the photo-source bottom sheet.
class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: kTextPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_left, size: 18, color: kGrey3Color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
