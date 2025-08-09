import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../project_resources/global_vars_andpaths.dart';
import '../app_start_package/splash_screendart.dart';

class Styles {}

class AppColors {
  static Color mainAppColor = const Color(0xffDE031B);
  static Color darkModeMain = const Color(0xffDE031B);
}

class ThemeSwap extends ChangeNotifier {
  int newcolorSeed = AppColors.mainAppColor.value;
  ThemePrefs _themePrefs = ThemePrefs();
  int get isColorSeed => newcolorSeed;

  ThemeSwap() {
    newcolorSeed = colorSeed;
    _themePrefs = ThemePrefs();
    getPrefs();
    notifyListeners();
  }
  set themeColor(int value) {
    newcolorSeed = value;
    _themePrefs.setTheme(value);
    notifyListeners();
  }

  getPrefs() async {
    newcolorSeed = await _themePrefs.getTheme();
    notifyListeners();
  }
}

class ThemePrefs {
  static const PREF_KEY = "apptheme";

  setTheme(int seedValue) async {
    SharedPreferences getPrefs = await SharedPreferences.getInstance();
    getPrefs.setInt(PREF_KEY, seedValue);
    getPrefs.reload();
    getTheme();
  }

  getTheme() async {
    SharedPreferences getPrefs = await SharedPreferences.getInstance();
    return getPrefs.getInt(PREF_KEY) ?? AppColors.mainAppColor.value;
  }
}
