import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../providers/profile_provider.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  final String userId;
  final String currentName;
  final String? currentBio;
  const EditProfileSheet({super.key, required this.userId, required this.currentName, this.currentBio});

  @override ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.currentName);
    _bio  = TextEditingController(text: widget.currentBio ?? '');
  }

  @override
  void dispose() { _name.dispose(); _bio.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _loading = true);
    await ref.read(profileProvider(widget.userId).notifier).updateProfile(
      name: _name.text.trim(),
      bio:  _bio.text.trim(),
    );
    if (mounted) { setState(() => _loading = false); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 3,
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text('Modifier mon profil', style: GoogleFonts.syne(
          fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.white)),
        const SizedBox(height: 16),
        TextField(
          controller: _name,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(labelText: 'Nom complet'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bio, maxLines: 3,
          style: const TextStyle(color: AppColors.white),
          decoration: const InputDecoration(labelText: 'Bio'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          child: _loading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text('Enregistrer'),
        ),
        const SizedBox(height: 16),
      ]),
    );
  }
}