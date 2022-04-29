import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData.from(
    colorScheme: const ColorScheme.light(
  brightness: Brightness.light,
  primary: CustomColors.wikimediaThemeBlue,
  onPrimary: Colors.white,
  secondary: Color.fromRGBO(151, 0, 0, 1.0),
  onSecondary: Colors.white,
  background: Color.fromRGBO(244, 244, 244, 1.0),
  onBackground: Colors.black,
  surface: Color.fromRGBO(252, 252, 252, 1.0),
  onSurface: Colors.black,
  error: Color.fromRGBO(151, 0, 0, 1.0),
  onError: Colors.white,
));

final ThemeData darkTheme = ThemeData.from(
    colorScheme: const ColorScheme.dark(
  brightness: Brightness.dark,
  primary: CustomColors.wikimediaThemeBlue,
  onPrimary: Colors.white,
  secondary: Color.fromRGBO(151, 0, 0, 1.0),
  onSecondary: Colors.white,
  background: Color.fromRGBO(28, 34, 39, 1.0),
  onBackground: Colors.white,
  surface: Color.fromRGBO(35, 44, 51, 1.0),
  onSurface: Colors.white,
  error: Color.fromRGBO(151, 0, 0, 1.0),
  onError: Colors.white,
)).copyWith(
    primaryColor: CustomColors.wikimediaThemeBlue,
    appBarTheme: const AppBarTheme(
      color: CustomColors.wikimediaThemeBlue,
    ),
    buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary));

class CustomColors {
  static const warningColor = Colors.amber;
  static const noImageColor = Colors.grey;
  static const noImageContentsColor = Colors.white70;
  static const wikimediaThemeBlue = Color.fromRGBO(0, 99, 152, 1.0);
  static const wikimediaLightBlue = Color.fromRGBO(234, 243, 255, 1.0);

  Color getDefaultIconColor(ThemeData themeData) {
    switch (themeData.brightness) {
      case Brightness.dark:
        return Colors.white70;
      case Brightness.light:
        return Colors.black45;
    }
  }
}
