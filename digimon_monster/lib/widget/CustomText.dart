import 'package:flutter/material.dart';

class CustomText extends Text {
  CustomText(
    String data, {
    double fontSize,
    Color color = Colors.white,
    TextAlign textAlign = TextAlign.center,
  }) : super(
          data,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
          ),
        );
}
