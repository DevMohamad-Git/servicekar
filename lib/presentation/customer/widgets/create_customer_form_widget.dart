import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/l10n/l10n.dart';

bool isValidIranMobilePhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return RegExp(r'^09\d{9}$').hasMatch(digits);
}

bool isValidEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
}

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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileImageSection(image: profileImage, onTap: onProfileImageTap),
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
                // Keep the digits LTR but right-align the field so the
                // numeric hint/input sit on the right edge like the RTL form.
                textAlign: TextAlign.right,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (value) => _validatePhone(context, value),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _AdditionalInfoSection(
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
                minLines: 4,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _validateName(BuildContext context, String? value) =>
      value == null || value.trim().isEmpty ? context.l10n.requiredField : null;

  String? _validatePhone(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) return context.l10n.requiredField;
    return isValidIranMobilePhone(value) ? null : context.l10n.invalidMobileNumber;
  }

  String? _validateEmail(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return isValidEmail(value) ? null : context.l10n.invalidEmail;
  }
}

class _ProfileImageSection extends StatelessWidget {
  const _ProfileImageSection({required this.image, required this.onTap});

  final XFile? image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = image != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.primary.withValues(alpha: 0.072),
            scheme.primary.withValues(alpha: 0.026),
          ],
        ),
      ),
      child: Column(
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
                            key: const ValueKey(
                              'create-customer-profile-preview',
                            ),
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainInfoSection extends StatelessWidget {
  const _MainInfoSection({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _SectionWithSurface(
      title: context.l10n.customerMainInfo,
      titleColor: scheme.onSurface,
      surfaceOpacity: 0.095,
      surfaceEndOpacity: 0.032,
      shadowOpacity: 0.035,
      children: children,
    );
  }
}

class _AdditionalInfoSection extends StatelessWidget {
  const _AdditionalInfoSection({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _SectionWithSurface(
      title: context.l10n.customerAdditionalInfo,
      leadingTitle: '(${context.l10n.optional})',
      titleColor: scheme.onSurfaceVariant,
      leadingColor: scheme.onSurfaceVariant.withValues(alpha: 0.62),
      surfaceOpacity: 0.072,
      surfaceEndOpacity: 0.026,
      shadowOpacity: 0.018,
      children: children,
    );
  }
}

class _SectionWithSurface extends StatelessWidget {
  const _SectionWithSurface({
    required this.title,
    required this.titleColor,
    required this.surfaceOpacity,
    required this.surfaceEndOpacity,
    required this.shadowOpacity,
    required this.children,
    this.leadingTitle,
    this.leadingColor,
  });

  final String title;
  final String? leadingTitle;
  final Color titleColor;
  final Color? leadingColor;
  final double surfaceOpacity;
  final double surfaceEndOpacity;
  final double shadowOpacity;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (leadingTitle != null) ...[
                const SizedBox(width: 6),
                Text(
                  leadingTitle!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: leadingColor ?? scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  scheme.primary.withValues(alpha: surfaceOpacity),
                  scheme.primary.withValues(alpha: surfaceEndOpacity),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: shadowOpacity),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
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
                  fontWeight: FontWeight.w600,
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
            hintText: hint == context.l10n.mobileNumberHint
                ? '09123456789'
                : hint,
            fillColor: Colors.white.withValues(alpha: 0.82),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: scheme.primary.withValues(alpha: 0.58),
                width: 1.5,
              ),
            ),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.68),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
