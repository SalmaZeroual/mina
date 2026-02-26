import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/services_provider.dart';
import '../../widgets/common/mina_button.dart';

class PublishServiceScreen extends StatefulWidget {
  const PublishServiceScreen({super.key});
  @override
  State<PublishServiceScreen> createState() => _PublishServiceScreenState();
}

class _PublishServiceScreenState extends State<PublishServiceScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _priceCtrl.dispose(); super.dispose(); }

  Future<void> _publish() async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    await context.read<ServicesProvider>().publishService({'title': _titleCtrl.text, 'description': _descCtrl.text, 'price': double.tryParse(_priceCtrl.text)});
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service published successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: const Text('Publish Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Service Title'),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'e.g. React Native App Development')),
            const SizedBox(height: 16),
            _label('Description'),
            TextField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(hintText: 'Describe your service in detail...')),
            const SizedBox(height: 16),
            _label('Price (USD)'),
            TextField(controller: _priceCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(hintText: '0.00', prefixText: '\$ ')),
            const SizedBox(height: 32),
            Consumer<ServicesProvider>(
              builder: (_, sp, __) => MinaButton(label: 'Publish Service', onPressed: _publish, isLoading: sp.isLoading),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
  );
}
