import 'package:flutter/material.dart';

/// Kickster / SportHeroes design tokens from Figma Style Guide.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF083879);
  static const Color primaryDark = Color(0xFF062C5C);
  static const Color primaryLight = Color(0xFF0A4A99);
  static const Color secondary = Color(0xFFF6F8FE);

  // Alerts
  static const Color success = Color(0xFF00C566);
  static const Color success700 = Color(0xFF009E52);
  static const Color success50 = Color(0xFFE6FAF0);
  static const Color error = Color(0xFFE53935);
  static const Color error700 = Color(0xFFC62828);
  static const Color error50 = Color(0xFFFDECEA);
  static const Color warning = Color(0xFFFACC15);
  static const Color warning700 = Color(0xFFCA8A04);
  static const Color warning50 = Color(0xFFFEF9C3);
  static const Color info = primary;
  static const Color info600 = Color(0xFF0A4A99);
  static const Color info50 = Color(0xFFE8EEF5);

  // Neutrals
  static const Color white = Color(0xFFFEFEFE);
  static const Color black = Color(0xFF111111);
  static const Color line = Color(0xFFE3E7EC);
  static const Color lineDark = Color(0xFF4A4A65);

  // Grayscale (Figma)
  static const Color greyscale10 = Color(0xFFFDFDFD);
  static const Color greyscale20 = Color(0xFFECF1F6);
  static const Color greyscale30 = Color(0xFFE3E9ED);
  static const Color greyscale40 = Color(0xFFD1D8DD);
  static const Color greyscale50 = Color(0xFFBFC6CC);
  static const Color greyscale60 = Color(0xFF9CA4AB);
  static const Color greyscale70 = Color(0xFF78828A);
  static const Color greyscale80 = Color(0xFF66707A);
  static const Color greyscale90 = Color(0xFF434E58);
  static const Color greyscale100 = Color(0xFF171725);

  // Brand scale
  static const Color primary900 = Color(0xFF041F40);
  static const Color primary800 = primaryDark;
  static const Color primary700 = primary;
  static const Color primary600 = primary;
  static const Color primary500 = primaryLight;
  static const Color primary400 = Color(0xFF3D6FA8);
  static const Color primary300 = Color(0xFF6F96C2);
  static const Color primary200 = Color(0xFFA1BCDC);
  static const Color primary100 = Color(0xFFD4E2F1);
  static const Color primary50 = Color(0xFFE8EEF5);
  static const Color primary25 = secondary;

  static const Color success900 = Color(0xFF006B38);
  static const Color success800 = Color(0xFF008546);
  static const Color success600 = Color(0xFF00B05C);
  static const Color success500 = success;
  static const Color success400 = Color(0xFF33D185);
  static const Color success300 = Color(0xFF66DC9F);
  static const Color success200 = Color(0xFF99E8BA);
  static const Color success100 = Color(0xFFCCF3DA);
  static const Color success25 = Color(0xFFF2FCF7);

  static const Color error900 = Color(0xFF8E1F1C);
  static const Color error800 = Color(0xFFB02A27);
  static const Color error600 = error;
  static const Color error500 = error;
  static const Color error400 = Color(0xFFEB615E);
  static const Color error300 = Color(0xFFF18986);
  static const Color error200 = Color(0xFFF6B1AF);
  static const Color error100 = Color(0xFFFAD8D7);
  static const Color error25 = Color(0xFFFEF6F6);

  static const Color warning900 = Color(0xFF854D0E);
  static const Color warning800 = Color(0xFFA16207);
  static const Color warning600 = Color(0xFFCA8A04);
  static const Color warning500 = warning;
  static const Color warning400 = Color(0xFFFDE047);
  static const Color warning300 = Color(0xFFFEE86B);
  static const Color warning200 = Color(0xFFFEEF8F);
  static const Color warning100 = Color(0xFFFEF9C3);
  static const Color warning25 = Color(0xFFFFFBEB);

  static const Color info900 = primary900;
  static const Color info800 = primaryDark;
  static const Color info700 = primary;
  static const Color info500 = primaryLight;
  static const Color info400 = primary400;
  static const Color info300 = primary300;
  static const Color info200 = primary200;
  static const Color info100 = primary100;
  static const Color info25 = secondary;

  static const Color backgroundLight = secondary;
  static const Color accent1 = primaryLight;

  // Material grey aliases used across the app
  static const Color grey900 = greyscale100;
  static const Color grey800 = Color(0xFF2A3140);
  static const Color grey700 = greyscale90;
  static const Color grey600 = greyscale80;
  static const Color grey500 = greyscale70;
  static const Color grey400 = greyscale60;
  static const Color grey300 = greyscale40;
  static const Color grey200 = greyscale30;
  static const Color grey100 = greyscale20;
  static const Color grey50 = secondary;
  static const Color grey25 = greyscale10;

  static const Color textPrimary = black;
  static const Color textSecondary = greyscale80;
  static const Color textTertiary = greyscale60;
}
