import 'package:flutter/foundation.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

/// Bottom navigation tabs, in display order.
enum AppTab { invoice, estimate, client, item, settings }

/// Owns the bottom navigation controller so any screen can switch tabs.
class NavigationProvider extends ChangeNotifier {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  PersistentTabController get controller => _controller;

  AppTab get currentTab => AppTab.values[_controller.index];

  void goToTab(AppTab tab) {
    if (_controller.index == tab.index) return;
    _controller.jumpToTab(tab.index);
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
