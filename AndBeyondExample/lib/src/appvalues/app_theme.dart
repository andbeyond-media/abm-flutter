import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const appThemeButtonColor = Color(0xff0F344F); //Color(0xff74BD43);
  static const appThemeColor = Color(0xff0F344F); //Color(0xff74BD43);
  static const appRedButtonColor = Color(0xffFD3D07);

  static const appThemeLightBackgroundColor = Color(0xffffffff);
  static Color appThemeDarkBackgroundColor = Colors.grey.shade900;
  static const appDarkThemeButtonBgColor = Color(0xff212936);

  static const appDarkButtonBgColorForSetting = Color(0xff394150);

  static const appLightThemeTextColor = Color(0xff000000);
  static const appDarkThemeTextColor = Color(0xffffffff);
  static const appBarCancelTextColor = Color(0xe66b7280);

  static Color appTextLightGrayColor = Colors.grey.shade500;
  static Color appTextDarkGrayColor = Colors.grey.shade700;

  static const fontFamilyNamePrimary = 'Montserrat';
  static const fontFamilyNameSecondary = 'Larsseit';
  static const fontReloceta = 'Recoleta';

  static const appThemeBoardBackgroundColor = Color(0xff394150);
}

class MyThemes {
  static final darkTheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: AppTheme.appThemeDarkBackgroundColor,
    primaryColor: Colors.black,
    colorScheme: const ColorScheme.dark().copyWith(primary: AppTheme.appThemeButtonColor),
  );

  static final lightTheme = ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: AppTheme.appThemeLightBackgroundColor,
      primaryColor: Colors.white,
      colorScheme: const ColorScheme.light().copyWith(primary: AppTheme.appThemeButtonColor),
      focusColor: AppTheme.appThemeButtonColor);
}
