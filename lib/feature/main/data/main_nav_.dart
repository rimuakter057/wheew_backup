import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

final ValueNotifier<int> mainNavIndex = ValueNotifier<int>(0);

/// The main-tab index to return to when leaving the Scan tab (index 4) via
/// its back button, since switching to it is a body-swap, not a pushed
/// route — there's nothing for GoRouter to pop back to.
final ValueNotifier<int> previousMainNavIndex = ValueNotifier<int>(0);

/// When `true`, a floating "Find Parking Spot" gradient button is shown
/// just above the bottom nav bar — triggered by ParkingShowScreen's
/// search-mode entry.
final RxBool showFindParkingButton = false.obs;