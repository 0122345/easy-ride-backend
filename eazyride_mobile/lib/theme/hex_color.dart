import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) {
      buffer.write('ff');
      buffer.write(hexColor.replaceFirst('#', ''));
    } else if (hexColor.length == 8) {
      buffer.write(hexColor.replaceFirst('#', ''));
    } else {
      throw int.parse(buffer.toString(), radix: 16);
    }
    return int.parse(buffer.toString(), radix: 16);
  }

  HexColor(String hexColor) : super(_getColorFromHex(hexColor));
}
