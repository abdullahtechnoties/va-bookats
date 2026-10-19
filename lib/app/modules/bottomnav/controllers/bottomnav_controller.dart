import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomnavController extends GetxController {
  static const int tabCount = 4;

  final RxInt tabIndex = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// Tabs whose page (and therefore controller) has already been built.
  ///
  /// Tab 0 is visible on launch, so it starts initialized. Every other tab
  /// is added the first time it is opened and then kept alive by the
  /// IndexedStack — so its controller is created once and never rebuilt
  /// (and never re-fetches) on later visits.
  final RxSet<int> initializedTabs = <int>{0}.obs;

  bool isTabInitialized(int index) => initializedTabs.contains(index);

  void changeTabIndex(int index) {
    if (index < 0 || index >= tabCount) return;
    if (!initializedTabs.contains(index)) initializedTabs.add(index);
    tabIndex.value = index;
  }

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }
}
