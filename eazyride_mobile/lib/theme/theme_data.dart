import 'package:eazyride_mobile/theme/hex_color.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: HexColor("#FFFFFF"),
  secondaryHeaderColor: HexColor("#EDAE10"),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Color.fromARGB(255, 4, 3, 10),
      fontSize: 20,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  secondaryHeaderColor: const Color.fromARGB(255, 56, 56, 56),
  textTheme:const TextTheme(
    bodyLarge: TextStyle(
      color: Color.fromARGB(255, 37, 106, 175),
      fontSize: 20,
    ),
  ),
);