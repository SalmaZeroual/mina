import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/cells_config.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/mina_text_field.dart';
import '../widgets/cell_search_picker.dart';
import '../widgets/cell_confirm_dialog.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form     = GlobalKey<FormState>();
  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _password = TextEditingController();
  int _step = 1; // 1 = infos, 2 = cellule

  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _onCellTapped(MinaCell cell) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => CellConfirmDialog(cell: cell),
    );
    if (confirmed == true) {
      await ref.read(authProvider.notifier).signUp(
        name:     _name.text.trim(),
        email:    _email.text.trim(),
        password: _password.text,
        cell:     cell,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (state is AuthRegistered) context.go('/verify-email', extra: state.email);
      if (state is AuthError) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
    });

    final loading = ref.watch(authProvider) is AuthLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _step == 1 ? _buildStep1(loading) : _buildStep2(loading),
        ),
      ),
    );
  }

  Widget _buildStep1(bool loading) => Form(
    key: _form,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () => context.go('/welcome'),
        child: Row(children: [
          const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.greyMuted),
          const Text(' Retour', style: TextStyle(color: AppColors.greyMuted, fontSize: 13)),
        ]),
      ),
      const SizedBox(height: 28),
      Text('Créer ton compte', style: GoogleFonts.syne(
        fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.white)),
      Text('Rejoins ta cellule professionnelle.',
        style: const TextStyle(color: AppColors.greyMuted, fontSize: 13)),
      const SizedBox(height: 32),
      MinaTextField(controller: _name, label: 'Nom complet',
        validator: (v) => v!.isEmpty ? 'Nom requis' : null),
      const SizedBox(height: 14),
      MinaTextField(controller: _email, label: 'Email',
        keyboardType: TextInputType.emailAddress,
        validator: (v) => v!.isEmpty ? 'Email requis' : null),
      const SizedBox(height: 14),
      MinaTextField(controller: _password, label: 'Mot de passe', obscure: true,
        validator: (v) => v!.length < 6 ? 'Min 6 caractères' : null),
      const SizedBox(height: 28),
      ElevatedButton(
        onPressed: loading ? null : () {
          if (_form.currentState!.validate()) setState(() => _step = 2);
        },
        child: const Text('Continuer →'),
      ),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('Déjà un compte ? ', style: TextStyle(color: AppColors.greyMuted)),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: const Text('Se connecter',
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ]),
    ]),
  );

  Widget _buildStep2(bool loading) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () => setState(() => _step = 1),
        child: Row(children: [
          const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.greyMuted),
          const Text(' Retour', style: TextStyle(color: AppColors.greyMuted, fontSize: 13)),
        ]),
      ),
      const SizedBox(height: 28),
      Text('Choisis ta cellule', style: GoogleFonts.syne(
        fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.white)),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warning.withOpacity(.3)),
        ),
        child: const Text('⚠️  Ce choix est définitif et ne peut jamais être modifié.',
          style: TextStyle(color: AppColors.warning, fontSize: 12)),
      ),
      const SizedBox(height: 20),
      if (loading)
        const Center(child: CircularProgressIndicator(color: AppColors.primary))
      else
        CellSearchPicker(onSelected: _onCellTapped),
    ],
  );
}