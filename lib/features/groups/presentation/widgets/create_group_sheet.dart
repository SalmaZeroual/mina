import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../providers/groups_provider.dart';

class CreateGroupSheet extends ConsumerStatefulWidget {
  const CreateGroupSheet({super.key});
  @override ConsumerState<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<CreateGroupSheet> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  bool _isPremium = false;
  int  _price     = 0;
  bool _loading   = false;

  @override
  void dispose() { _name.dispose(); _desc.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await ref.read(groupsProvider.notifier).createGroup(
      name:        _name.text.trim(),
      description: _desc.text.trim().isNotEmpty ? _desc.text.trim() : null,
      isPremium:   _isPremium,
      priceDa:     _price,
    );
    if (mounted) { setState(() => _loading = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 3,
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text('Nouveau groupe', style: GoogleFonts.syne(
          fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.white)),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(labelText: 'Nom du groupe'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _desc,
          maxLines: 2,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(labelText: 'Description (optionnel)'),
        ),
        const SizedBox(height: 14),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Groupe premium', style: GoogleFonts.syne(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.white)),
          value: _isPremium,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _isPremium = v),
        ),
        if (_isPremium)
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(labelText: 'Prix (DA/mois)'),
            onChanged: (v) => _price = int.tryParse(v) ?? 0,
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Créer le groupe'),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}