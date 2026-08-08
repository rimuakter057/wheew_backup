import "package:flutter/material.dart";

class AppColors {

  static const Color lightBlue = Color(0xFFE9EFF6);
  static const Color lightBlue1 = Color(0xFFDEE7F0);
  static const Color lightBlue2 = Color(0xFFD0DCE8);
  static const Color blueGrey = Color(0xFFB6C5DA);
  static const Color bulShadeGradient = Color(0xFFC6D2E2);
  static const Color blackButton = Color(0xFF404040);
  static const Color containerBg = Color(0xFFC6D2E2);




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

  static const LinearGradient blackGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      blackButton,
      black

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

  // static const LinearGradient blackGradient = LinearGradient(
  //   begin: Alignment.topCenter,
  //   end: Alignment.bottomCenter,
  //   colors: [
  //     Colors.white,
  //     notificationBoxColor,
  //   ],
  // );

  static const Color blue = Color(0xFF1070B7);
  static const Color darBlue = Color(0xFF014495);
  static const Color blueShadeConBg = Color(0xFFBDC9D7);
  static const Color topBorderBlue = Color(0xFF81ADD5);
  static const Color black = Color(0xFF333333);
  static const Color divider = Color(0xFFC0CCDC);
  static const Color gradientOne =    Color(0xFF0C7DC9);
  static  Color gradientTwo =    Color(0xFF014495);

  static const Color white = Color(0xFFFFFFFF);
  static const Color iceBlue = Color(0xFFC5D0E0);
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
  static const Color greyText = Color(0xFF5D6065);
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

  // Vehicle color picker swatches (Figma spec)
  static const Color vehicleColorBlu = Color(0xFF0070B6);
  static const Color vehicleColorArancione = Color(0xFFDE6402);
  static const Color vehicleColorRosso = Color(0xFFEB2329);
  static const Color vehicleColorNero = Color(0xFF202125);
  static const Color vehicleColorGrigioArgento = Color(0xFFA0A1A6);
  static const Color vehicleColorBianco = Color(0xFFF5F5F5);

  static const Color vehicleColorBluBorder = Color(0xFF7FB7DA);
  static const Color vehicleColorArancioneBorder = Color(0xFFEFB383);
  static const Color vehicleColorRossoBorder = Color(0xFFF59396);
  static const Color vehicleColorNeroBorder = Color(0xFF939496);
  static const Color vehicleColorGrigioArgentoBorder = Color(0xFFCECFD1);
  static const Color vehicleColorBiancoBorder = Color(0xFFFFFFFF);

  // Standard Flutter named color aliases
  static const Color transparent = Colors.transparent;
  static const Color pureBlack = Color(0xFF000000);
  static const Color black87 = Colors.black87;
  static const Color black54 = Colors.black54;
  static const Color black45 = Colors.black45;
  static const Color black38 = Colors.black38;
  static const Color black26 = Colors.black26;
  static const Color black12 = Colors.black12;
  static const Color white70 = Colors.white70;
  static const Color white60 = Colors.white60;
  static const Color white54 = Colors.white54;
  static const Color white38 = Colors.white38;
  static const Color white30 = Colors.white30;
  static const Color white24 = Colors.white24;
  static const Color white12 = Colors.white12;
  static const Color white10 = Colors.white10;

  static const MaterialColor amber = Colors.amber;
  static const Color starAmber = Color(0xFFFFC107);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const MaterialColor orange = Colors.orange;
  static const MaterialColor yellow = Colors.yellow;
  static const MaterialColor green = Colors.green;
  static const MaterialAccentColor greenAccent = Colors.greenAccent;
  static const MaterialAccentColor redAccent = Colors.redAccent;
  static const MaterialColor indigo = Colors.indigo;
  static const MaterialColor purple = Colors.purple;
  static const MaterialColor grey = Colors.grey;
  static const MaterialColor materialBlue = Colors.blue;
  static const MaterialColor materialRed = Colors.red;

  // Material Grey Shades
  static const Color greyShade50 = Color(0xFFFAFAFA);
  static const Color greyShade100 = Color(0xFFF5F5F5);
  static const Color greyShade200 = Color(0xFFEEEEEE);
  static const Color greyShade300 = Color(0xFFE0E0E0);
  static const Color greyShade400 = Color(0xFFBDBDBD);
  static const Color greyShade500 = Color(0xFF9E9E9E);
  static const Color greyShade600 = Color(0xFF757575);
  static const Color greyShade700 = Color(0xFF616161);
  static const Color greyShade800 = Color(0xFF424242);
  static const Color greyShade900 = Color(0xFF212121);

  // Common UI Hex tokens
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color darkSlate2 = Color(0xFF1D2939);
  static const Color slateLight = Color(0xFFF1F5F9);
  static const Color slateBorder = Color(0xFFE5E7EB);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color darkRedButton = Color(0xFFB02517);
  static const Color deepRedBorder = Color(0xFF7A1C15);
  static const Color brightBlueButton = Color(0xFF0062E0);
  static const Color darkBlueButton = Color(0xFF014495);
  static const Color inputFillBg = Color(0xFFDDE2ED);
  static const Color deepRedBg = Color(0xFF4A0F0A);
  static const Color darkNavy = Color(0xFF1A1A2E);
}
