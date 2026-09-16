import 'package:flutter/material.dart';
import 'package:invoicemaker/core/design/tokens.dart';
import 'package:invoicemaker/core/extensions/build_context_ext.dart';

/// The app's screen shell.
///
/// Centres and caps the content width so a form does not stretch into an
/// unreadable line on a tablet, and keeps every screen's app bar identical.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.floatingActionButton,
    this.bottomBar,
    this.bottomNavigationBar,
    this.maxContentWidth = Layout.readableWidth,
    this.showAppBar = true,
    this.resizeToAvoidBottomInset = true,
    this.leading,
  });

  final Widget body;

  final String? title;

  /// Replaces [title] when the bar needs more than text.
  final Widget? titleWidget;

  final List<Widget> actions;
  final Widget? floatingActionButton;

  /// Pinned above the bottom edge, for a primary save action.
  final Widget? bottomBar;

  final Widget? bottomNavigationBar;

  /// Content wider than this is centred with gutters either side.
  final double maxContentWidth;

  final bool showAppBar;
  final bool resizeToAvoidBottomInset;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: showAppBar
          ? AppBar(
              leading: leading,
              title: titleWidget ??
                  (title == null
                      ? null
                      : Text(
                          title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )),
              actions: [
                ...actions,
                if (actions.isNotEmpty) Gap.w4,
              ],
            )
          : null,
      body: SafeArea(
        top: !showAppBar,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ConstrainedContent(maxWidth: maxContentWidth, child: body),
            ),
            // The action bar lives in the body, not in a Scaffold slot. The
            // navigation-bar slot is for navigation, and putting a bar this
            // tall there leaves a floating SnackBar no room, which Scaffold
            // asserts on. In the body it also stays above the keyboard.
            if (bottomBar != null) bottomBar!,
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Caps and centres its child's width.
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({
    super.key,
    required this.child,
    this.maxWidth = Layout.readableWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// A bar pinned to the bottom of a form holding its main action.
///
/// Sits above the keyboard and the gesture inset, so the save button is
/// always reachable while typing.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    super.key,
    required this.children,
    this.spacing = Insets.md,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: EdgeInsets.fromLTRB(
        Insets.gutter,
        Insets.md,
        Insets.gutter,
        Insets.md + context.bottomSafeInset,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          top: BorderSide(color: palette.border),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          // Keeps the buttons a readable width on a tablet instead of
          // stretching them the whole way across.
          constraints: const BoxConstraints(maxWidth: Layout.readableWidth),
          child: Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) SizedBox(width: spacing),
                // The last action gets the most room: it is the primary one.
                Expanded(
                  flex: i == children.length - 1 ? 3 : 2,
                  child: children[i],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Standard padding for a scrollable screen body.
class ScreenPadding extends StatelessWidget {
  const ScreenPadding({super.key, required this.child, this.withBottomGap = true});

  final Widget child;

  /// Adds room at the bottom so the last row clears a floating button.
  final bool withBottomGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Insets.gutter,
        Insets.lg,
        Insets.gutter,
        withBottomGap ? Insets.scrollBottom : Insets.lg,
      ),
      child: child,
    );
  }
}
