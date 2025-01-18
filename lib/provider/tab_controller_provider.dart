import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class TabControllerProvider with ChangeNotifier {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  PersistentTabController get controller => _controller;

  void setTabIndex(int index) {
    _controller.jumpToTab(index);
    notifyListeners();
  }
}
