import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../providers/marketplace_provider.dart';

class AddServiceScreen extends ConsumerStatefulWidget {
  const AddServiceScreen({super.key});
  @override ConsumerState<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends ConsumerState<AddServiceScreen> {
  final _form  = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc  = TextEditingController();
  final _price = TextEditingController();
  String _unit = 'session';
  bool _loading = false;

  static const _units = ['session', 'projet', 'heure', 'mois', 'jour'];

  @override
  void dispose() { _title.dispose(); _desc.dispose(); _price.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    await ref.read(marketplaceProvider.notifier).createService(
      title:       _title.text.trim(),
      description: _desc.text.trim(),
      priceDa:     int.parse(_price.text.trim()),
      unit:        _unit,
    );
    if (mounted) { setState(() => _loading = false); context.pop(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('Titre', style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.greyMuted)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _title,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(hintText: 'Ex: Coaching Levée de Fonds'),
              validator: (v) => v!.trim().isEmpty ? 'Requis' : null,
            ),

            const SizedBox(height: 16),
            Text('Description', style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.greyMuted)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _desc, maxLines: 3,
              style: const TextStyle(color: AppColors.white),
              decoration: const InputDecoration(hintText: 'Décris ce que tu offres...'),
              validator: (v) => v!.trim().isEmpty ? 'Requis' : null,
            ),

            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prix (DA)', style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.greyMuted)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _price, keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(hintText: '5000'),
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Requis';
                      if (int.tryParse(v.trim()) == null) return 'Nombre invalide';
                      if (int.parse(v.trim()) <= 0) return '> 0';
                      return null;
                    },
                  ),
                ],
              )),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unité', style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.greyMuted)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _unit,
                        dropdownColor: AppColors.surface2,
                        style: const TextStyle(color: AppColors.white, fontSize: 14),
                        isExpanded: true,
                        items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (v) => setState(() => _unit = v!),
                      ),
                    ),
                  ),
                ],
              )),
            ]),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Publier le service'),
            ),
          ]),
        ),
      ),
    );
  }
}