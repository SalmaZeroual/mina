import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/cells_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class CellConfirmDialog extends StatelessWidget {
  final MinaCell cell;
  const CellConfirmDialog({super.key, required this.cell});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Confirmer ta cellule', style: GoogleFonts.syne(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cell.color.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cell.color.withOpacity(.3)),
            ),
            child: Row(children: [
              Text(cell.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Text(cell.label, style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 16, color: cell.color)),
            ]),
          ),
          const SizedBox(height: 14),
          Text(AppStrings.cellWarning,
            style: const TextStyle(color: AppColors.greyMuted, fontSize: 13, height: 1.5)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Changer', style: TextStyle(color: AppColors.greyMuted)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}