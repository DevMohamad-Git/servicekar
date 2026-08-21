import 'package:flutter/material.dart';

import '../../../config/themes/app_themes.dart';

/// Reusable, UI-only search field for the customer list.
///
/// The callback is intentionally optional: this task only presents the field
/// and does not connect it to a search use case, query, or debounce.
///
/// Rendered as a filled rounded field (16dp, matching the card radius) with
/// a faint near-white surface and a barely-there gray outline when idle,
/// switching to a blue outline on focus. In RTL the search icon sits on the
/// start (right) side. Tapping anywhere outside the field unfocuses it so
/// the soft keyboard closes.
class CustomerSearchBarWidget extends StatefulWidget {
  const CustomerSearchBarWidget({
    super.key,
    this.onChanged,
    this.initialValue = '',
  });

  final ValueChanged<String>? onChanged;
  final String initialValue;

  @override
  State<CustomerSearchBarWidget> createState() =>
      _CustomerSearchBarWidgetState();
}

class _CustomerSearchBarWidgetState extends State<CustomerSearchBarWidget> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        textInputAction: TextInputAction.search,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'جستجو در مشتریان',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 22,
            color: scheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: kBackgroundColor,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kGrey4Color),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kGrey4Color),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: scheme.primary.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}
