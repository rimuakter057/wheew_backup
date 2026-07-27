import "package:flutter/material.dart";

class AppColors {

  static const Color lightBlue = Color(0xFFE3EAF2);
  static const Color lightBlue1 = Color(0xFFDEE7F0);
  static const Color lightBlue2 = Color(0xFFD0DCE8);
  static const Color blueGrey = Color(0xFFB6C5DA);
  static const Color bulShadeGradient = Color(0xFFC6D2E2);


  static const LinearGradient primaryBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      lightBlue,
      lightBlue1,
      lightBlue2,
      blueGrey,
    ],
  );


  static const LinearGradient containerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
    white,
      blueShadeConBg

    ],
  );


  // Custom Button Colors
  static const Color buttonGradientColor1 = Color(0xFF0C7DC9);
  static const Color buttonGradientColor2 = Color(0xFF014495);
  static const Color buttonShadowColor = Color(0xFF587CA7);
  static const Color parkingConBg = Color(0xFFC6D2E2);
  static const Color redBg1 = Color(0xFFB23216);
  static const Color redBg2 = Color(0xFF992E16);
  static const Color redBg3 = Color(0xFF68120E);

  // Custom Button Gradient
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      buttonGradientColor1,
      buttonGradientColor2,
      buttonGradientColor1,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [
      redBg1,
      redBg2,
      redBg3,
      redBg2,
      redBg1,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient parkingContainerGradient = LinearGradient(
    colors: [
      white,
      parkingConBg
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color notificationBg = Color(0xFFE5EBF2);
  static const Color notificationBoxBorder = Color(0xFFC8D3E3);
  static const Color notificationBoxColor = Color(0xFFECF1F6);
  static const Color blackGrey = Color(0xFF3F3F40);

  static const LinearGradient notificationBoxGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
    blackGrey,
      black,
    ],
  );

  static const LinearGradient blackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white,
      notificationBoxColor,
    ],
  );

  static const Color blue = Color(0xFF1070B7);
  static const Color darBlue = Color(0xFF014495);
  static const Color blueShadeConBg = Color(0xFFBDC9D7);
  static const Color topBorderBlue = Color(0xFF81ADD5);
  static const Color black = Color(0xFF333333);
  static const Color divider = Color(0xFFC0CCDC);
  static const Color gradientOne =    Color(0xFF0C7DC9);
  static  Color gradientTwo =    Color(0xFF014495);

  static const Color white = Color(0xFFFFFFFF);
  static const Color textBlack = Color(0xFF333333);
  static const Color primaryText = Color(0xFF1E1E1E);
  static const Color secondaryText = Color(0xFF555555);
  static const Color errorColor = Color(0xFFCC0F0F);

  static const Color backgroundColor = Color(0xFFFFFFFF);

  static const Color borderColor = Color(0xFF1070B7);
  static const Color inputBorderColor = Color(0x78787833);
  static const Color brandHoverColor = Color(0xFF1070B7);
  static const Color softBrandColor = Color(0xFFE6ECF5);
  static const Color successColor = Color(0xFF28A745);
  static const Color greyShade = Color(0xffEEF0F4);
  //static const Color blueBox = Color(0xFF0088FF); //#0088FF
  static const Color blueBox = Color(0xFF0088FF); //#0088FF
  //static const Color green = Color(0xFF3AAA35);
  static const Color greenClient = Color(0xFFadd4a4);
  static const Color deleteButton = Color(0xFFe41713);
  static const Color greyBg = Color(0xFFFAFAFA);
  static const Color greyBorder = Color(0xFFE0E0E0);
  static const Color red = Color(0xFFEF4444);
  static const Color paidBlue = Color(0xFF1D4ED8);
  static const Color freeWhite = Color(0xFFFFFFFF);
  static const Color chargingGreen = Color(0xFF15803D);
  static const Color disableOrange = Color(0xFFF97316);
  static const Color rating = Color(0xFFFBBF24);




  static const Color bianco = Color(0xFFF4F4F2);
  static const Color nero = Color(0xFF1B1B1D);
  static const Color grigioArgento = Color(0xFF888B8D);
  static const Color blu = Color(0xFF0070B6);
  static const Color rosso = Color(0xFFD41B19);
  static const Color verde = Color(0xFF0AA409);
  static const Color marroneBronzo = Color(0xFF784520);

}
