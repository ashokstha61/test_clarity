// import 'dart:ui';

// class ThemeData {
//   Color lightPrimaryColor = const Color.fromRGBO(18, 24, 42, 1.000);
// }

import 'package:flutter/material.dart';

class ThemeHelper {
  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color.fromRGBO(41, 41, 102, 1.0);
  }

  static Color backgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 32, 32, 45)
        : Colors.white;
  }

  static Color appBarTitle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color formTitle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF3B3B7A);
  }

  static Color textTitle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF3B3B7A);
  }

  static Color customListTileColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Color.fromRGBO(50, 67, 118, 1.000);
  }

  static Color textSubtitle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Color.fromRGBO(50, 67, 118, 1.000);
  }

  static Color soundTitle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Color.fromRGBO(50, 67, 118, 1.000);
  }

  static Color iconColorRemix(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color iconAndTextColorRemix(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color textColorTimer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color timerBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Color.fromRGBO(34, 32, 51, 1)
        : Colors.white;
  }

  static Color timerscreenBackgrundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color.fromRGBO(18, 23, 42, 1)
        : Colors.white;
  }

  static Color registerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 32, 32, 45)
        : Colors.white;
  }

  static Color registerTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color loginAndRegisterTitleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color registerBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color loginAndRegisterBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 32, 32, 45)
        : Colors.white;
  }

  static Color iconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color.fromARGB(255, 57, 70, 96);
  }

  static Color textFieldFillColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
  }
}
