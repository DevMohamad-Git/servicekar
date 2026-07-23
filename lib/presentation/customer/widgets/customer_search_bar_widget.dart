import 'package:flutter/material.dart';

import '../../../config/l10n/l10n.dart';

/// Reusable search field used by the list page. Pure presentation: the
/// caller wires [onChanged] to the controller.
class CustomerSearchBarWidget extends StatefulWidget {
  const CustomerSearchBarWidget({
    super.key,
    required this.onChanged,
    this.initialValue = '',
  });

  final ValueChanged<String> onChanged;
  final String initialValue;

  @override
  State<CustomerSearchBarWidget> createState() =>
      _CustomerSearchBarWidgetState();
}

class _CustomerSearchBarWidgetState
    extends State<CustomerSearchBarWidget> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        // `InputDecoration` itself is non-const because
        // `context.l10n.searchCustomers` is a runtime call; inner
        // widgets like `prefixIcon` and `border` keep their own
        // `const` keywords so Material 3 rebuild only the parts
        // whose strings changed.
        decoration: InputDecoration(
          hintText: context.l10n.searchCustomers,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
