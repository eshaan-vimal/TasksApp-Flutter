import 'package:flutter/material.dart';


Color strengthenColour (Color colour, double factor)
{
  int r = (colour.r * 255 * factor).clamp(0, 255).toInt();
  int g = (colour.g * 255 * factor).clamp(0, 255).toInt();
  int b = (colour.b * 255 * factor).clamp(0, 255).toInt();
  
  return Color.fromARGB(255, r, g, b);
}


String rgbToHex (Color colour)
{
  String r = (colour.r * 255).toInt().toRadixString(16).padLeft(2, '0');
  String g = (colour.g * 255).toInt().toRadixString(16).padLeft(2, '0');
  String b = (colour.b * 255).toInt().toRadixString(16).padLeft(2, '0');

  return '$r$g$b';
}


Color hexToRgb (String hexColour)
{
  return Color(int.parse(hexColour, radix: 16) + 0xFF000000);
}


int getWeekOffset (DateTime picked)
{
  DateTime now = DateTime.now();

  picked = DateTime(picked.year, picked.month, picked.day);
  now = DateTime(now.year, now.month, now.day);

  DateTime pickedStart = picked.subtract(Duration(days: picked.weekday - 1));
  DateTime nowStart = now.subtract(Duration(days: now.weekday - 1));

  return pickedStart.difference(nowStart).inDays ~/ 7;
}


List<DateTime> getWeekDates (int weekOffset)
{
  final today = DateTime.now();

  DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  startOfWeek = startOfWeek.add(Duration(days: weekOffset * 7));

  return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
}
