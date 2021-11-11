import 'package:flutter/material.dart';

final ThemeData lightTheme = new ThemeData.from(colorScheme: ColorScheme.light(
  brightness: Brightness.light,
  primary: CustomColors.WIKIMEDIA_THEME_COLOR,
));

final ThemeData darkTheme = new ThemeData.from(colorScheme: ColorScheme.dark(
  brightness: Brightness.dark,
  primary: CustomColors.WIKIMEDIA_THEME_COLOR,
  secondary: CustomColors.WIKIMEDIA_THEME_COLOR,
)).copyWith(
  appBarTheme: AppBarTheme(
    color: CustomColors.WIKIMEDIA_THEME_COLOR,
  )
);

class CustomColors {
  static const WARNING_COLOR = Colors.amber;
  static const NO_IMAGE_COLOR = Colors.grey;
  static const NO_IMAGE_CONTENTS_COLOR = Colors.white70;
  static const WIKIMEDIA_THEME_COLOR = Color.fromRGBO(0, 99, 152, 1.0);
}
