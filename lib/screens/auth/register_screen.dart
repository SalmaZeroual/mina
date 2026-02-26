import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../widgets/common/mina_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppTheme.primary));
      return;
    }
    final success = await context.read<AuthProvider>().register(_nameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.selectCell);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _label('Full Name'),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'John Doe')),
            const SizedBox(height: 16),
            _label('Email'),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'john@example.com')),
            const SizedBox(height: 16),
            _label('Password'),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
              ),
            ),
            const SizedBox(height: 16),
            _label('Confirm Password'),
            TextField(
              controller: _confirmCtrl,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                hintText: '••••••••',
                suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
              ),
            ),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (_, auth, __) => MinaButton(label: 'Continue', onPressed: _register, isLoading: auth.status == AuthStatus.loading),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'By creating an account, you agree to our ',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  children: [
                    TextSpan(text: 'Terms of Service', style: const TextStyle(color: AppTheme.primary)),
                    const TextSpan(text: ' and '),
                    TextSpan(text: 'Privacy Policy', style: const TextStyle(color: AppTheme.primary)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
  );
}
