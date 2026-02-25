import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/mina_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form     = GlobalKey<FormState>();
  final _email    = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await ref.read(authProvider.notifier).signIn(_email.text.trim(), _password.text);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (state is AuthAuthenticated) context.go('/home');
      if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ));
      }
    });

    final loading = ref.watch(authProvider) is AuthLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                RichText(text: TextSpan(children: [
                  TextSpan(text: 'M', style: GoogleFonts.syne(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  TextSpan(text: 'ina', style: GoogleFonts.syne(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.white)),
                ])),
                const SizedBox(height: 6),
                Text('Content de te revoir 👋',
                  style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.white)),
                const SizedBox(height: 36),
                MinaTextField(controller: _email, label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Email requis' : null),
                const SizedBox(height: 14),
                MinaTextField(controller: _password, label: 'Mot de passe', obscure: true,
                  validator: (v) => v!.isEmpty ? 'Mot de passe requis' : null),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Se connecter'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Pas encore de compte ? ", style: TextStyle(color: AppColors.greyMuted)),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text('Rejoindre Mina',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}