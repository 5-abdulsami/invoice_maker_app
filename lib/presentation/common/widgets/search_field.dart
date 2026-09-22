import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';

/// An inline search box.
///
/// Sits in the screen body rather than replacing the app-bar title, so it is
/// always visible: search is a primary way to find a document once there are
/// more than a screenful.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.onChanged,
    this.hint = 'Search',
    this.initialValue = '',
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final String initialValue;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialValue);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  /// Rebuilds so the clear button appears and disappears with the text.
  void _onControllerChanged() => setState(() {});

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    context.dismissKeyboard();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasText = _controller.text.isNotEmpty;

    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      onTapOutside: (_) => context.dismissKeyboard(),
      style: context.text.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(
          Icons.search,
          size: IconSizes.md,
          color: palette.textTertiary,
        ),
        suffixIcon: hasText
            ? IconButton(
                onPressed: _clear,
                icon: const Icon(Icons.close, size: IconSizes.sm),
                tooltip: 'Clear search',
              )
            : null,
        // Comfortable height without the label a form field would carry.
        contentPadding: const EdgeInsets.symmetric(vertical: Insets.md),
      ),
    );
  }
}
