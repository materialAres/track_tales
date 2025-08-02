import 'package:flutter/material.dart';

class CustomTextTheme extends ThemeExtension<CustomTextTheme> {
  final TextStyle boldText;
  final TextStyle bodyText;

  const CustomTextTheme({
    required this.boldText,
    required this.bodyText,
  });

  @override
  CustomTextTheme copyWith({
    TextStyle? boldText,
    TextStyle? bodyText,
  }) {
    return CustomTextTheme(
      boldText: boldText ?? this.boldText,
      bodyText: bodyText ?? this.bodyText,
    );
  }

  @override
  CustomTextTheme lerp(ThemeExtension<CustomTextTheme>? other, double t) {
    if (other is! CustomTextTheme) {
      return this;
    }
    return CustomTextTheme(
      boldText: TextStyle.lerp(boldText, other.boldText, t)!,
      bodyText: TextStyle.lerp(bodyText, other.bodyText, t)!,
    );
  }
}