import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/l10n/l10n.dart';
import '../../../config/themes/app_themes.dart';

/// True when [value] is an Iranian mobile number: 11 digits starting with 09.
///
/// Input may contain visual separators (spaces, dashes); only digits are
/// considered, matching the digits-only input formatter applied to the field.
bool isValidIranMobilePhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return RegExp(r'^09\d{9}$').hasMatch(digits);
}

/// Lightweight sanity check for the optional email field.
bool isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
}

/// The Create Customer form body: profile placeholder, required info, and
/// additional info.
///
/// Presentation-only — the `TextEditingController`s and the submit seam live
/// in [CreateCustomerPage], so this widget stays independent of persistence.
class CreateCustomerFormWidget extends StatelessWidget {
  const CreateCustomerFormWidget({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.notesController,
    required this.profileImage,
    required this.onProfileImageTap,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController notesController;
  final XFile? profileImage;
  final VoidCallback onProfileImageTap;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      // Validate as the user interacts so inline errors explain *why* the
      // primary CTA is disabled without requiring a submit attempt.
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileImageSection(
            image: profileImage,
            onTap: onProfileImageTap,
          ),
          const SizedBox(height: 16),
          _MainInfoSection(
            children: [
              _CreateField(
                label: context.l10n.fullName,
                hint: context.l10n.fullNameHint,
                controller: fullNameController,
                required: true,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                textCapitalization: TextCapitalization.words,
                validator: (value) => _validateName(context, value),
              ),
              _CreateField(
                label: context.l10n.mobileNumber,
                hint: context.l10n.mobileNumberHint,
                controller: phoneController,
                required: true,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (value) => _validatePhone(context, value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FormSectionCard(
            icon: Icons.notes_outlined,
            title: context.l10n.customerAdditionalInfo,
            subtitle: context.l10n.optional,
            children: [
              _CreateField(
                label: context.l10n.email,
                hint: context.l10n.emailHint,
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                validator: (value) => _validateEmail(context, value),
              ),
              _CreateField(
                label: context.l10n.address,
                hint: context.l10n.addressHint,
                controller: addressController,
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.streetAddressLine1],
                textCapitalization: TextCapitalization.sentences,
              ),
              _CreateField(
                label: context.l10n.notes,
                hint: context.l10n.notesHint,
                controller: notesController,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _validateName(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.requiredField;
    }
    return null;
  }

  String? _validatePhone(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.requiredField;
    }
    if (!isValidIranMobilePhone(value)) {
      return context.l10n.invalidMobileNumber;
    }
    return null;
  }

  String? _validateEmail(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!isValidEmail(value)) {
      return context.l10n.invalidEmail;
    }
    return null;
  }
}

/// Minimal profile avatar and action. The selected [XFile] is a temporary
/// presentation value; durable copying belongs to the submit/storage flow.
class _ProfileImageSection extends StatelessWidget {
  const _ProfileImageSection({
    required this.image,
    required this.onTap,
  });

  final XFile? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = image != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: hasImage
              ? context.l10n.changeProfilePhoto
              : context.l10n.addProfilePhoto,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('create-customer-profile-avatar'),
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.24),
                  ),
                ),
                child: ClipOval(
                  child: image == null
                      ? Icon(
                          Icons.person_outline_rounded,
                          size: 48,
                          color: scheme.primary,
                        )
                      : Image.file(
                          File(image!.path),
                          key: const ValueKey('create-customer-profile-preview'),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image_outlined,
                            size: 42,
                            color: scheme.primary,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onTap,
          icon: Icon(
            hasImage ? Icons.edit_outlined : Icons.add_a_photo_outlined,
            size: 18,
          ),
          label: Text(
            hasImage
                ? context.l10n.changeProfilePhoto
                : context.l10n.addProfilePhoto,
          ),
          style: TextButton.styleFrom(
            foregroundColor: scheme.primary,
            textStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// Minimal identity section for the two primary customer fields. Unlike the
/// optional-information section below, it intentionally has no surrounding
/// card so the avatar and inputs read as one light, breathable composition.
class _MainInfoSection extends StatelessWidget {
  const _MainInfoSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 12),
          child: Text(
            context.l10n.customerMainInfo,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          children[i],
        ],
      ],
    );
  }
}

/// White rounded card that groups optional fields under a titled header.
class _FormSectionCard extends StatelessWidget {
  const _FormSectionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: _cardDecoration(scheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primary.withValues(alpha: 0.10),
                ),
                child: Icon(icon, size: 20, color: scheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// A label-above-input field matching the reference mockup: a right-aligned
/// (start-aligned in RTL) label with an optional red asterisk, then a filled
/// rounded field using the global `inputDecorationTheme`.
class _CreateField extends StatelessWidget {
  const _CreateField({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.required = false,
    this.keyboardType,
    this.textInputAction,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.autofillHints,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final bool required;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: labelStyle?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textDirection: textDirection,
          textAlign: textAlign,
          autofillHints: autofillHints,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          minLines: minLines,
          maxLines: maxLines,
          scrollPadding: const EdgeInsets.only(bottom: 140),
          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration(ColorScheme scheme) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: kGrey4Color.withValues(alpha: 0.9)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
