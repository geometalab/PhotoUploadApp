import 'package:flutter/material.dart';

final ThemeData lightTheme = new ThemeData.from(
    colorScheme: ColorScheme.light(
        brightness: Brightness.light,
        primary: CustomColors.WIKIMEDIA_THEME_BLUE,
        primaryVariant: Color.fromRGBO(0, 69, 108, 1.0),
        onPrimary: Colors.white,
        secondary: Color.fromRGBO(151, 0, 0, 1.0),
        secondaryVariant: Color.fromRGBO(110, 10, 10, 1.0),
        onSecondary: Colors.white,
        background: Color.fromRGBO(244, 244, 244, 1.0),
        onBackground: Colors.black,
        surface: Color.fromRGBO(252, 252, 252, 1.0),
        onSurface: Colors.black));

final ThemeData darkTheme = new ThemeData.from(
        colorScheme: ColorScheme.dark(
            brightness: Brightness.dark,
            primary: CustomColors.WIKIMEDIA_THEME_BLUE,
            primaryVariant: Color.fromRGBO(0, 112, 183, 1.0),
            onPrimary: Colors.white,
            secondary: Color.fromRGBO(151, 0, 0, 1.0),
            secondaryVariant: Color.fromRGBO(191, 24, 24, 1.0),
            onSecondary: Colors.white,
            background: Color.fromRGBO(28, 34, 39, 1.0),
            onBackground: Colors.white,
            surface: Color.fromRGBO(35, 44, 51, 1.0),
            onSurface: Colors.white))
    .copyWith(
        primaryColor: CustomColors.WIKIMEDIA_THEME_BLUE,
        appBarTheme: AppBarTheme(
          color: CustomColors.WIKIMEDIA_THEME_BLUE,
        ),
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary));

class CustomColors {
  static const WARNING_COLOR = Colors.amber;
  static const NO_IMAGE_COLOR = Colors.grey;
  static const NO_IMAGE_CONTENTS_COLOR = Colors.white70;
  static const WIKIMEDIA_THEME_BLUE = Color.fromRGBO(0, 99, 152, 1.0);
}
