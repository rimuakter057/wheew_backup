// utils বা helper ফাইলে রাখুন
import 'package:platchatapp/utils/assets_path/assets_path.dart';

String getDisabledLocationIcon(String? location) {
  switch (location?.toUpperCase()) {
    case 'ALL':
      return AssetsPath.all;
    case 'BACK':
      return AssetsPath.back;
    case 'RIGHT':
      return AssetsPath.right;
    case 'LEFT':
      return AssetsPath.left;
    case 'NONE':
    default:
      return AssetsPath.none;
  }
}