import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// Nav bar now only shows Parking(1) / Chat(2) / Profile(3) — Home(0) and
// Save Parking(5) stay reachable in code but default to Parking on launch.
final ValueNotifier<int> mainNavIndex = ValueNotifier<int>(1);

/// The main-tab index to return to when leaving the Scan tab (index 4) via
/// its back button, since switching to it is a body-swap, not a pushed
/// route — there's nothing for GoRouter to pop back to.
final ValueNotifier<int> previousMainNavIndex = ValueNotifier<int>(1);

/// When `true`, a floating "Find Parking Spot" gradient button is shown
/// just above the bottom nav bar — triggered by ParkingMapScreen's
/// search-mode entry.
final RxBool showFindParkingButton = false.obs;