import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyEmailScreen({super.key, required this.email});
  @override ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

  Future<void> _submit() async {
    if (_code.length < 6) return;
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).verifyEmail(
      email: widget.email,
      code: _code,
    );
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _resend() async {
    await ref.read(authProvider.notifier).resendCode(email: widget.email);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nouveau code envoyé !')));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, state) {
      if (state is AuthAuthenticated) context.go('/home');
      if (state is AuthError) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.go('/register'),
              child: Row(children: [
                const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.greyMuted),
                const Text(' Retour', style: TextStyle(color: AppColors.greyMuted, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 32),
            Text('Vérifie ton email', style: GoogleFonts.syne(
              fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.white)),
            const SizedBox(height: 8),
            RichText(text: TextSpan(children: [
              const TextSpan(text: 'Code envoyé à ',
                style: TextStyle(color: AppColors.greyMuted, fontSize: 13)),
              TextSpan(text: widget.email,
                style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ])),
            const SizedBox(height: 40),

            // 6 cases du code
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) => SizedBox(
                width: 46, height: 56,
                child: TextField(
                  controller: _ctrls[i],
                  focusNode: _nodes[i],
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.syne(
                    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.white),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) {
                      _nodes[i + 1].requestFocus();
                    }
                    if (v.isEmpty && i > 0) {
                      _nodes[i - 1].requestFocus();
                    }
                    if (_code.length == 6) _submit();
                  },
                ),
              )),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: (_loading || _code.length < 6) ? null : _submit,
              child: _loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Vérifier'),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _resend,
                child: RichText(text: const TextSpan(children: [
                  TextSpan(text: 'Pas reçu ? ',
                    style: TextStyle(color: AppColors.greyMuted, fontSize: 13)),
                  TextSpan(text: 'Renvoyer le code',
                    style: TextStyle(color: AppColors.primary,
                      fontSize: 13, fontWeight: FontWeight.w700)),
                ])),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}