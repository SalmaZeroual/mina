import 'package:flutter/material.dart';
import 'app_colors.dart';

enum MinaCell {
  entrepreneur,
  ingenieur,
  createur,
  professeur,
  medecin,
  financier;

  String get id => name;

  String get label {
    switch (this) {
      case MinaCell.entrepreneur: return 'Entrepreneur';
      case MinaCell.ingenieur:    return 'Ingénieur';
      case MinaCell.createur:     return 'Créateur';
      case MinaCell.professeur:   return 'Professeur';
      case MinaCell.medecin:      return 'Médecin';
      case MinaCell.financier:    return 'Financier';
    }
  }

  String get emoji {
    switch (this) {
      case MinaCell.entrepreneur: return '🚀';
      case MinaCell.ingenieur:    return '⚙️';
      case MinaCell.createur:     return '🎨';
      case MinaCell.professeur:   return '📚';
      case MinaCell.medecin:      return '💊';
      case MinaCell.financier:    return '📈';
    }
  }

  Color get color {
    switch (this) {
      case MinaCell.entrepreneur: return AppColors.primary;
      case MinaCell.ingenieur:    return const Color(0xFF3EDFA0);
      case MinaCell.createur:     return const Color(0xFFFF9F43);
      case MinaCell.professeur:   return const Color(0xFF60BFFF);
      case MinaCell.medecin:      return const Color(0xFFFF6CAE);
      case MinaCell.financier:    return const Color(0xFFB39DDB);
    }
  }

  static MinaCell fromString(String v) =>
      MinaCell.values.firstWhere((c) => c.name == v,
          orElse: () => MinaCell.entrepreneur);
}