import 'package:flutter/material.dart';

ThemeData getApplicationTheme(){
  return ThemeData(
        fontFamily: 'OpenSans Regular',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontFamily: 'OpenSans Regular'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          ),
        ),
      );
}