import 'package:flutter/material.dart';

class CellModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  CellModel({required this.id, required this.name, required this.description, required this.icon});

  static List<CellModel> get all => [
    CellModel(id: 'web_dev', name: 'Web Development', description: 'Frontend, Backend, Full-stack developers', icon: Icons.code),
    CellModel(id: 'medicine', name: 'Medicine', description: 'Doctors, Nurses, Healthcare professionals', icon: Icons.medical_services_outlined),
    CellModel(id: 'business', name: 'Business', description: 'Entrepreneurs, Managers, Consultants', icon: Icons.business_center_outlined),
    CellModel(id: 'photography', name: 'Photography', description: 'Photographers, Videographers, Visual artists', icon: Icons.camera_alt_outlined),
    CellModel(id: 'design', name: 'Design', description: 'UI/UX, Graphic design, Product design', icon: Icons.palette_outlined),
    CellModel(id: 'real_estate', name: 'Real Estate', description: 'Agents, Brokers, Property managers', icon: Icons.real_estate_agent_outlined),
    CellModel(id: 'education', name: 'Education', description: 'Teachers, Professors, Instructors', icon: Icons.school_outlined),
    CellModel(id: 'engineering', name: 'Engineering', description: 'Mechanical, Civil, Electrical engineers', icon: Icons.settings_outlined),
    CellModel(id: 'marketing', name: 'Marketing', description: 'Digital marketers, SEO, Brand managers', icon: Icons.trending_up_outlined),
    CellModel(id: 'finance', name: 'Finance', description: 'Accountants, Analysts, Financial advisors', icon: Icons.account_balance_outlined),
    CellModel(id: 'legal', name: 'Legal', description: 'Lawyers, Paralegals, Legal consultants', icon: Icons.gavel_outlined),
    CellModel(id: 'fitness', name: 'Fitness & Sports', description: 'Trainers, Coaches, Athletes', icon: Icons.fitness_center_outlined),
  ];
}
