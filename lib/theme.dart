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
        ? const Color.fromRGBO(41, 41, 102, 1.0)
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
}
