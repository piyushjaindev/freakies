import 'package:flutter/material.dart';

ThemeData appTheme() {
  Color primaryColor = Color(0xff222A85);
  Color textColor = Color(0xFF31353A);
  Color errorColor = Color(0xFFE64926);
  ThemeData baseTheme = ThemeData.light();

  FloatingActionButtonThemeData fabTheme() {
    return baseTheme.floatingActionButtonTheme
        .copyWith(backgroundColor: Color(0xFFE64926), elevation: 4.0);
  }

  InputDecorationTheme inputDecorationTheme() {
    return baseTheme.inputDecorationTheme.copyWith(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
                color: primaryColor, width: 1.0, style: BorderStyle.solid)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
                color: primaryColor, width: 1.0, style: BorderStyle.solid)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
                color: errorColor, width: 1.0, style: BorderStyle.solid)),
        fillColor: Colors.white,
        filled: true,
        hintStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: Color(0xFF6A7989),
            letterSpacing: 0),
        errorStyle: TextStyle(height: 0.3, color: errorColor, fontSize: 8.0));
  }

  TextTheme textTheme() {
    return baseTheme.textTheme.copyWith(
      title: TextStyle(
        fontFamily: 'NotoSerif',
        letterSpacing: 1.0,
        wordSpacing: 2.0,
        fontSize: 25.0,
      ),
      subtitle: TextStyle(
        fontFamily: 'NotoSerif',
        fontSize: 15.0,
        letterSpacing: 0,
        color: textColor,
      ),
      subhead: TextStyle(
        fontFamily: 'NotoSerif',
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: textColor,
      ),
      body1: TextStyle(
        fontFamily: 'NotoSerif',
        fontSize: 20.0,
        color: textColor,
      ),
      body2: TextStyle(
          fontFamily: 'NotoSerif', fontSize: 25.0, color: textColor, height: 1),
    );
  }

  AppBarTheme appBarTheme() {
    return baseTheme.appBarTheme.copyWith(
        elevation: 6,
        color: Colors.white,
        textTheme: textTheme()
            .copyWith(title: textTheme().title.copyWith(color: primaryColor)),
        actionsIconTheme: IconThemeData(
          size: 35.0,
          color: primaryColor,
        ),
        iconTheme: IconThemeData(
          size: 35.0,
          color: primaryColor,
        ));
  }

  IconThemeData iconTheme() {
    return baseTheme.iconTheme.copyWith(
      size: 35.0,
      color: errorColor,
    );
  }

  ButtonThemeData buttonTheme() {
    return baseTheme.buttonTheme.copyWith(
        buttonColor: primaryColor,
        padding: EdgeInsets.all(5.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        textTheme: ButtonTextTheme.primary);
  }

  SliderThemeData sliderThemeData() {
    return baseTheme.sliderTheme.copyWith(
        activeTrackColor: primaryColor,
        inactiveTrackColor: Color(0xFF6A7989),
        minThumbSeparation: 20,
        showValueIndicator: ShowValueIndicator.always,
        valueIndicatorColor: primaryColor,
        thumbColor: primaryColor,
        valueIndicatorTextStyle: TextStyle(
          fontFamily: 'NotoSerif',
          fontSize: 15.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.8,
        ));
  }

  SnackBarThemeData snackBarThemeData() {
    return baseTheme.snackBarTheme.copyWith(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF6A7989),
        contentTextStyle: TextStyle(
            fontFamily: 'NotoSerif',
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.8,
            color: Colors.white));
  }

  TabBarTheme tabBarTheme() {
    return baseTheme.tabBarTheme.copyWith(
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: primaryColor,
        unselectedLabelColor: textColor,
        labelStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'NotoSerif'),
        unselectedLabelStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w400,
            fontFamily: 'NotoSerif'));
  }

  return baseTheme.copyWith(
      primaryColor: primaryColor,
      accentColor: Color(0xFF6A7989),
      scaffoldBackgroundColor: Color(0xFFDBE4F0),
      floatingActionButtonTheme: fabTheme(),
      textTheme: textTheme(),
      appBarTheme: appBarTheme(),
      inputDecorationTheme: inputDecorationTheme(),
      buttonTheme: buttonTheme(),
      iconTheme: iconTheme(),
      sliderTheme: sliderThemeData(),
      snackBarTheme: snackBarThemeData(),
      indicatorColor: primaryColor,
      tabBarTheme: tabBarTheme());
}
