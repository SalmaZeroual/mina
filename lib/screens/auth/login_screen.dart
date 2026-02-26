import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../widgets/common/mina_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!), backgroundColor: AppTheme.primary));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Text('Mina', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              const SizedBox(height: 8),
              const Text('Professional social network', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 48),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Consumer<AuthProvider>(
                builder: (_, auth, __) => MinaButton(
                  label: 'Login',
                  onPressed: _login,
                  isLoading: auth.status == AuthStatus.loading,
                ),
              ),
              const SizedBox(height: 12),
              MinaButton(
                label: 'Create Account',
                isOutlined: true,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showForgotPassword,
                child: const Text('Forgot password?', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500)),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPassword() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Forgot Password'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Enter your email')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().forgotPassword(ctrl.text);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset link sent to your email')),
                );
              }
            },
            child: const Text('Send', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}
