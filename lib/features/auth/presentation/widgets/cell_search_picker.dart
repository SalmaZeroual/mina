import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/cells_config.dart';
import '../../../../core/constants/app_colors.dart';

class CellSearchPicker extends StatefulWidget {
  final void Function(MinaCell) onSelected;
  const CellSearchPicker({super.key, required this.onSelected});

  @override
  State<CellSearchPicker> createState() => _CellSearchPickerState();
}

class _CellSearchPickerState extends State<CellSearchPicker> {
  final _ctrl = TextEditingController();
  List<MinaCell> _results = MinaCell.values;
  MinaCell? _selected;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onSearch(String q) {
    setState(() {
      _results = q.isEmpty
          ? MinaCell.values
          : MinaCell.values
              .where((c) => c.label.toLowerCase().startsWith(q.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Barre de recherche
      TextField(
        controller: _ctrl,
        onChanged: _onSearch,
        style: const TextStyle(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Recherche ta cellule...',
          prefixIcon: const Icon(Icons.search, color: AppColors.greyMuted, size: 20),
          suffixIcon: _ctrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.greyMuted, size: 18),
                  onPressed: () { _ctrl.clear(); _onSearch(''); },
                )
              : null,
        ),
      ),
      const SizedBox(height: 16),

      // Résultats
      if (_results.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text('Aucune cellule trouvée',
              style: TextStyle(color: AppColors.greyMuted, fontSize: 13)),
          ),
        )
      else
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final cell = _results[i];
            final sel  = _selected == cell;
            return GestureDetector(
              onTap: () {
                setState(() => _selected = cell);
                widget.onSelected(cell);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: sel ? cell.color.withOpacity(.1) : AppColors.surface,
                  border: Border.all(
                    color: sel ? cell.color : AppColors.border,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Row(children: [
                  Text(cell.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                  Text(cell.label, style: GoogleFonts.syne(
                    fontWeight: FontWeight.w700, fontSize: 14,
                    color: sel ? cell.color : AppColors.white)),
                  const Spacer(),
                  if (sel)
                    Icon(Icons.check_circle, color: cell.color, size: 20),
                ]),
              ),
            );
          },
        ),
    ]);
  }
}