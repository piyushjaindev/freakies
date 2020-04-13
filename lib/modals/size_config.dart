import 'package:flutter/cupertino.dart';

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double mainWidth;
  static double mainHeight;

  void init(BuildContext context) {
    double safeAreaHorizontal;
    double safeAreaVertical;
    double screenWidth;
    double screenHeight;
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    safeAreaHorizontal = _mediaQueryData.padding.left +
        _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top +
        _mediaQueryData.padding.bottom;
    mainWidth = screenWidth - safeAreaHorizontal;
    mainHeight = screenHeight - safeAreaVertical;
  }
}