import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../providers/auth_provider.dart';

class PublishServiceScreen extends StatefulWidget {
  const PublishServiceScreen({super.key});
  @override
  State<PublishServiceScreen> createState() => _PublishServiceScreenState();
}

class _PublishServiceScreenState extends State<PublishServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  int _currentStep = 0;

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose(); super.dispose(); }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '.'));
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    await context.read<ServicesProvider>().publishService({
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'price': price,
    });
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('🎉 Your service is now live on the marketplace!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellName = context.watch<AuthProvider>().currentUser?.cell ?? 'your cell';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Offer a Service', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Consumer<ServicesProvider>(
            builder: (_, sp, __) => TextButton(
              onPressed: sp.isLoading ? null : _publish,
              child: sp.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Publish', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary.withOpacity(0.08), AppTheme.primary.withOpacity(0.03)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
              ),
              child: Row(children: [
                const Text('🌍', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Reach a global audience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Your service will be visible to all $cellName professionals on Mina worldwide.',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4)),
                ])),
              ]),
            ),
            const SizedBox(height: 20),

            // Title
            _Card(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Service Title', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'e.g. "I will build your React Native app"',
                    filled: true, fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    counterText: '${_titleCtrl.text.length}/80',
                  ),
                  maxLength: 80,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) => Text(
                    '$currentLength/$maxLength',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  validator: (v) => (v == null || v.trim().length < 5) ? 'Title must be at least 5 characters' : null,
                ),
                const SizedBox(height: 6),
                const Text('💡 Be specific. "I will design your mobile app UI in Figma" converts better than "Design services".',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.4)),
              ]),
            ),

            const SizedBox(height: 12),

            // Description
            _Card(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Description', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Describe exactly what you offer, your process, deliverables and timeline...',
                    filled: true, fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v == null || v.trim().length < 20) ? 'Please write at least 20 characters' : null,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: ['What you deliver', 'Your process', 'Timeline', 'Revisions policy']
                      .map((t) => GestureDetector(
                        onTap: () {
                          final hint = '✅ $t: ';
                          if (!_descCtrl.text.contains(hint)) {
                            _descCtrl.text += (_descCtrl.text.isEmpty ? '' : '\n') + hint;
                            _descCtrl.selection = TextSelection.fromPosition(TextPosition(offset: _descCtrl.text.length));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('+ $t', style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                        ),
                      ))
                      .toList(),
                ),
              ]),
            ),

            const SizedBox(height: 12),

            // Price
            _Card(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('Starting Price (USD)', required: true),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    width: 48, height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                    ),
                    alignment: Alignment.center,
                    child: const Text('\$', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        filled: true, fillColor: const Color(0xFFF5F6FA),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Price is required';
                        final p = double.tryParse(v.replaceAll(',', '.'));
                        if (p == null || p <= 0) return 'Enter a valid price';
                        return null;
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 10),
                // Quick price buttons
                Row(children: [
                  const Text('Quick set:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(width: 8),
                  ...[50, 100, 250, 500, 1000].map((p) => GestureDetector(
                    onTap: () => setState(() => _priceCtrl.text = '$p'),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _priceCtrl.text == '$p' ? AppTheme.primary : const Color(0xFFF0F1F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('\$$p', style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: _priceCtrl.text == '$p' ? Colors.white : AppTheme.textSecondary,
                      )),
                    ),
                  )),
                ]),
              ]),
            ),

            const SizedBox(height: 24),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Text('💡', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text('Pro tips to get more clients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF92400E))),
                ]),
                const SizedBox(height: 10),
                ...[
                  'Use numbers in your title ("5 years experience", "24h delivery")',
                  'Mention your tools and technologies',
                  'Set a competitive starting price — you can negotiate',
                  'Respond fast to first messages: it builds trust',
                ].map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('• ', style: TextStyle(color: Color(0xFFB45309), fontWeight: FontWeight.bold)),
                    Expanded(child: Text(tip, style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.4))),
                  ]),
                )),
              ]),
            ),

            const SizedBox(height: 32),

            // Submit button
            Consumer<ServicesProvider>(
              builder: (_, sp, __) => SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: sp.isLoading ? null : _publish,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: sp.isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.rocket_launch_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Publish to Marketplace', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ]),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) => RichText(
    text: TextSpan(
      text: text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary),
      children: required ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
    ),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: child,
  );
}