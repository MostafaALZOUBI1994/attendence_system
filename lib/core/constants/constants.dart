import 'dart:ui';

import 'package:flutter/cupertino.dart';

const Color primaryColor =  Color(0xFFB8860B);
const Color secondaryColor = Color.fromRGBO(65, 64, 66, 1.0);
const Color lightGray = Color.fromRGBO(198, 198, 198, 1.0);
const Color veryLightGray = Color.fromRGBO(225, 225, 225, 1.0);
const String baseUrl = 'https://taapi.moec.gov.ae/api/lgt/';
const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFFD700), // Light gold
    Color(0xFFB8860B), // Darker gold
    Color(0xFFB8860B), //
  ],
);
const String empID = 'EMP_ID';
const String empName = 'EMP_NAME';
const String empNameAR = 'EMP_NAME_AR';
const String profileImage = 'PROFILE_IMAGE';
const String checkIns = 'CHECK_INS';
const String localeKey = 'locale';