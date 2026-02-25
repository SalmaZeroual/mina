import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';

class CellBanner extends ConsumerWidget {
  const CellBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    if (state is! AuthAuthenticated) return const SizedBox();
    final cell = state.user.cell;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cell.color.withOpacity(.07),
        border: Border(bottom: BorderSide(color: cell.color.withOpacity(.2))),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(
            shape: BoxShape.circle, color: cell.color,
            boxShadow: [BoxShadow(color: cell.color.withOpacity(.6), blurRadius: 5)],
          )),
          const SizedBox(width: 10),
          Text('${cell.emoji}  CELLULE ${cell.label.toUpperCase()}',
            style: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w800,
              letterSpacing: .07, color: cell.color)),
          const Spacer(),
          Text('1 847 membres', style: TextStyle(fontSize: 11, color: Colors.white38)),
        ],
      ),
    );
  }
}
