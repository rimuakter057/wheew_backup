import 'package:flutter/foundation.dart';


final ValueNotifier<int> mainNavIndex = ValueNotifier<int>(0);

/// The main-tab index to return to when leaving the Scan tab (index 4) via
/// its back button, since switching to it is a body-swap, not a pushed
/// route — there's nothing for GoRouter to pop back to.
final ValueNotifier<int> previousMainNavIndex = ValueNotifier<int>(0);