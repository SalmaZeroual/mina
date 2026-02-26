import 'package:flutter/material.dart';

class CellModel {
  final String id;
  final String name;
  final String description;
  final String icon;

  CellModel({required this.id, required this.name, required this.description, required this.icon});

  factory CellModel.fromJson(Map<String, dynamic> json) {
    return CellModel(id: json['id'], name: json['name'], description: json['description'] ?? '', icon: json['icon'] ?? '');
  }

  IconData get iconData {
    const map = {
      'code': Icons.code,
      'medical_services': Icons.medical_services_outlined,
      'business_center': Icons.business_center_outlined,
      'camera_alt': Icons.camera_alt_outlined,
      'palette': Icons.palette_outlined,
      'real_estate_agent': Icons.real_estate_agent_outlined,
      'school': Icons.school_outlined,
      'settings': Icons.settings_outlined,
      'trending_up': Icons.trending_up_outlined,
      'account_balance': Icons.account_balance_outlined,
      'gavel': Icons.gavel_outlined,
      'fitness_center': Icons.fitness_center_outlined,
    };
    return map[icon] ?? Icons.circle_outlined;
  }
}