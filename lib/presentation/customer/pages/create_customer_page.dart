import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';
import '../../../injection/global_providers.dart';
import '../services/profile_image_picker.dart';
import '../widgets/create_customer_form_widget.dart';
import '../widgets/customer_page_header.dart';
import 'create_customer_submit.dart';

/// Create customer page with live customer and profile-image persistence.
///
/// The page owns only form state and the temporary picker [XFile]. The live
/// submit adapter copies that temporary file into app-private storage before
/// passing its relative path to the existing customer persistence flow.
@RoutePage()
class CreateCustomerPage extends ConsumerStatefulWidget {
  const CreateCustomerPage({
    super.key,
    this.initialDraft,
    this.profileImagePicker,
  });

  /// Optional pre-filled values for previews and tests. Defaults to an empty
  /// form, which is the runtime state.
  final CreateCustomerDraft? initialDraft;

  /// Injectable picker boundary used by tests; production uses image_picker.
  final ProfileImagePicker? profileImagePicker;

  @override
  ConsumerState<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends ConsumerState<CreateCustomerPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName = TextEditingController(
    text: widget.initialDraft?.fullName ?? '',
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.initialDraft?.phoneNumber ?? '',
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.initialDraft?.email ?? '',
  );
  late final TextEditingController _address = TextEditingController(
    text: widget.initialDraft?.address ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.initialDraft?.notes ?? '',
  );
  late final ProfileImagePicker _profileImagePicker =
      widget.profileImagePicker ?? ProfileImagePicker();
  XFile? _profileImage;
  bool _submitting = false;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _fullName.text.trim().isNotEmpty && isValidIranMobilePhone(_phone.text);

  void _resetForm() {
    _fullName.clear();
    _phone.clear();
    _email.clear();
    _address.clear();
    _notes.clear();
    _profileImage = null;
    // Recreate the form key so every field drops its value, error, and
    // "has interacted" state in one clean rebuild — avoids the stale
    // `FormField.initialValue` re-population that `FormState.reset()`
    // triggers for controller-backed fields.
    _formKey = GlobalKey<FormState>();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final submit = ref.read(createCustomerSubmitProvider);
    final failure = await submit(
      CreateCustomerDraft(
        fullName: _fullName.text.trim(),
        phoneNumber: _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        profileImageTempPath: _profileImage?.path,
      ),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (failure == null) {
      ref
          .read(appHelperProvider)
          .displayToast(context, message: context.l10n.customerCreated);
      await _profileImagePicker.discard(_profileImage);
      _resetForm();
    } else {
      ref
          .read(appHelperProvider)
          .displayToast(context, message: failure, isError: true);
    }
  }

  Future<void> _openProfileImageActions() async {
    final action = await showModalBottomSheet<_ProfileImageAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(sheetContext.l10n.camera),
              onTap: () => Navigator.of(sheetContext).pop(
                _ProfileImageAction.camera,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(sheetContext.l10n.gallery),
              onTap: () => Navigator.of(sheetContext).pop(
                _ProfileImageAction.gallery,
              ),
            ),
            if (_profileImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(sheetContext.l10n.removeProfilePhoto),
                onTap: () => Navigator.of(sheetContext).pop(
                  _ProfileImageAction.remove,
                ),
              ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;
    if (action == _ProfileImageAction.remove) {
      // No durable file exists before submit. Remove the picker cache file
      // owned by this form session before dropping the reference.
      final previousImage = _profileImage;
      setState(() => _profileImage = null);
      await _profileImagePicker.discard(previousImage);
      return;
    }

    final source = action == _ProfileImageAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;
    final result = await _profileImagePicker.pick(source);
    if (!mounted) return;

    if (result.isSelected && result.file != null) {
      final previousImage = _profileImage;
      if (previousImage?.path != result.file!.path) {
        await _profileImagePicker.discard(previousImage);
      }
      if (!mounted) return;
      setState(() => _profileImage = result.file);
    } else if (result.isFailed) {
      ref.read(appHelperProvider).displayToast(
        context,
        message: context.l10n.profilePhotoError,
        isError: true,
      );
    }
    // Cancellation intentionally leaves the previous selection untouched.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: CustomerPageHeader(
        title: context.l10n.newCustomer,
        onBack: () => context.router.maybePop(),
        actions: [
          ListenableBuilder(
            listenable: Listenable.merge([_fullName, _phone]),
            builder: (context, _) => TextButton(
              onPressed: _submitting || !_isFormValid ? null : _submit,
              child: Text(context.l10n.save),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: CreateCustomerFormWidget(
                formKey: _formKey,
                fullNameController: _fullName,
                phoneController: _phone,
                emailController: _email,
                addressController: _address,
                notesController: _notes,
                profileImage: _profileImage,
                onProfileImageTap: _openProfileImageActions,
              ),
            ),
          ),
          ListenableBuilder(
            listenable: Listenable.merge([_fullName, _phone]),
            builder: (context, _) => _SubmitActionBar(
              submitting: _submitting,
              enabled: _isFormValid,
              onSubmit: _submit,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ProfileImageAction { camera, gallery, remove }

/// Bottom-pinned primary CTA. Stays above the keyboard and within one-hand
/// reach; disabled while the required fields are invalid or a submit is in
/// flight.
class _SubmitActionBar extends StatelessWidget {
  const _SubmitActionBar({
    required this.submitting,
    required this.enabled,
    required this.onSubmit,
  });

  final bool submitting;
  final bool enabled;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: kGrey4Color.withValues(alpha: 0.8)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: submitting || !enabled ? null : onSubmit,
            style: FilledButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: submitting
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scheme.onPrimary,
                      ),
                    ),
                  )
                : Text(context.l10n.createCustomer),
          ),
        ),
      ),
    );
  }
}
