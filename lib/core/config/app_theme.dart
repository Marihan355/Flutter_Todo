import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';

final Color primaryBlue = const Color(0xFF0A3D62);

final ThemeData appTheme = ThemeData(
  primaryColor: primaryBlue,
  colorScheme: ColorScheme.fromSeed(seedColor: primaryBlue),
  //textTheme: GoogleFonts.poppinsTextTheme(),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryBlue,
  ),
);