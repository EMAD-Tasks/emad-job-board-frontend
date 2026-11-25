import 'package:flutter/material.dart';

class BoardStyle {
  static const List<Color> pinColors = [
    Color(0xFFD94E4E), // Rosso
    Color(0xFF2B5943), // Verde lavagna
    Color(0xFFD98A2B), // Ambra
    Color(0xFF3B6E8C), // Blu ardesia
  ];

  static const List<Color> noteColors = [
    Color(0xFFFFFDF7), // Carta avorio
    Color(0xFFFFF8DC), // Post-it crema
    Color(0xFFF4F9F4), // Salvia chiarissimo
    Color(0xFFF3F7FA), // Carta azzurrina
  ];

  static Color pinColorFor(String annuncioId) {
    return pinColors[annuncioId.hashCode.abs() % pinColors.length];
  }

  static Color noteColorFor(String annuncioId) {
    return noteColors[annuncioId.hashCode.abs() % noteColors.length];
  }
}