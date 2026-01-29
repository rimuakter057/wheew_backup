import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  // ----------------- MEDIA QUERY -----------------
  double get height => MediaQuery.of(this).size.height;

  double get width => MediaQuery.of(this).size.width;

  // ----------------- TEXT THEME -----------------
  TextTheme get textTheme => Theme.of(this).textTheme;
  TextStyle get headlineLarge => textTheme.headlineLarge ?? const TextStyle();
  TextStyle get headlineMedium => textTheme.headlineMedium ?? const TextStyle();
  TextStyle get headlineSmall => textTheme.headlineSmall ?? const TextStyle();
  TextStyle get titleLarge => textTheme.titleLarge ?? const TextStyle();
  TextStyle get titleMedium => textTheme.titleMedium ?? const TextStyle();
  TextStyle get titleSmall => textTheme.titleSmall ?? const TextStyle();
  TextStyle get bodyLarge => textTheme.bodyLarge ?? const TextStyle();
  TextStyle get bodyMedium => textTheme.bodyMedium ?? const TextStyle();
  TextStyle get bodySmall => textTheme.bodySmall ?? const TextStyle();
  TextStyle get labelLarge => textTheme.labelLarge ?? const TextStyle();
  TextStyle get labelMedium => textTheme.labelMedium ?? const TextStyle();
  TextStyle get labelSmall => textTheme.labelSmall ?? const TextStyle();
}
