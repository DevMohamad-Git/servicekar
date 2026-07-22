import 'package:flutter/material.dart';

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
  State<CustomerSearchBarWidget> createState() => _CustomerSearchBarWidgetState();
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          // TODO: AppLocalizations.of(context).customersSearchHint
          hintText: 'Search customers',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
