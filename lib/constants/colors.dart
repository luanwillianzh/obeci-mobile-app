import 'package:flutter/material.dart';

class OBECIColors {
  // Cores base
  static const Color background = Color(0xFFFFFFFF); // #ffffff
  static const Color foreground = Color(0xFF171717); // #171717
  
  // Cores OBECI
  static const Color cor1 = Color(0xFFFEDFCD); // #fedfcd
  static const Color cor2 = Color(0xFFF2B694); // #f2b694
  static const Color cor3 = Color(0xFFD97C50); // #d97c50
  static const Color cor4 = Color(0xFFF8894A); // #f8894a
  
  // Cores derivadas para uso no tema
  static const Color primary = cor4; // Cor primária baseada na cor4 OBECI
  static const Color secondary = cor2; // Cor secundária baseada na cor2 OBECI
  static const Color accent = cor3; // Cor de destaque baseada na cor3 OBECI
  static const Color surface = background; // Cor de superfície
  static const Color onSurface = foreground; // Cor para texto em superfícies
  static const Color error = Color(0xFFE53935); // Vermelho material design para erros
  static const Color onError = Colors.white; // Cor para texto em erros
}