import 'package:flutter/material.dart';
import 'package:invoicemaker/core/constants/app_colors.dart';

/// An app bar whose title swaps for a search field when search is tapped.
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required this.title,
    required this.onQueryChanged,
    this.hintText = 'Search',
    this.actions = const [],
  });

  final String title;
  final ValueChanged<String> onQueryChanged;
  final String hintText;

  /// Actions shown after the search button while search is closed.
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.clear();
    widget.onQueryChanged('');
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSearching) {
      return AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => setState(() => _isSearching = true),
            icon: const Icon(Icons.search),
          ),
          ...widget.actions,
        ],
      );
    }

    return AppBar(
      leading: IconButton(
        tooltip: 'Close search',
        onPressed: _close,
        icon: const Icon(Icons.arrow_back),
      ),
      title: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(color: AppColors.white, fontSize: 18),
        cursorColor: AppColors.white,
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: AppColors.lightBlue),
        ),
        onChanged: widget.onQueryChanged,
      ),
      actions: [
        IconButton(
          tooltip: 'Clear',
          onPressed: () {
            _controller.clear();
            widget.onQueryChanged('');
          },
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
