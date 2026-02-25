import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/cells_config.dart';

class CellTag extends StatelessWidget {
  final MinaCell cell;
  final bool small;
  const CellTag({super.key, required this.cell, this.small = false});

  @override
  Widget build(BuildContext context) {
    final size = small ? 9.0 : 10.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 7 : 8, vertical: 2),
      decoration: BoxDecoration(
        color: cell.color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cell.color.withOpacity(.3)),
      ),
      child: Text(
        '${cell.emoji} ${cell.label}',
        style: GoogleFonts.syne(fontSize: size, fontWeight: FontWeight.w700, color: cell.color),
      ),
    );
  }
}