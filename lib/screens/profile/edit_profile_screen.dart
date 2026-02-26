import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/common/mina_button.dart';
import '../../widgets/common/avatar_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _aboutCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileProvider>().user ?? UserModel.mock;
    _nameCtrl = TextEditingController(text: user.fullName);
    _titleCtrl = TextEditingController(text: user.title);
    _locationCtrl = TextEditingController(text: user.location ?? '');
    _companyCtrl = TextEditingController(text: user.company ?? '');
    _aboutCtrl = TextEditingController(text: user.about ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _titleCtrl.dispose();
    _locationCtrl.dispose(); _companyCtrl.dispose(); _aboutCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<ProfileProvider>().updateProfile({
      'full_name': _nameCtrl.text, 'title': _titleCtrl.text,
      'location': _locationCtrl.text, 'company': _companyCtrl.text, 'about': _aboutCtrl.text,
    });
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<ProfileProvider>().user ?? UserModel.mock;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  AvatarWidget(initials: user.initials, size: 80),
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _field('Full Name', _nameCtrl),
            _field('Professional Title', _titleCtrl, hint: 'e.g. Senior React Developer'),
            _field('Location', _locationCtrl, hint: 'e.g. San Francisco, CA'),
            _field('Company', _companyCtrl, hint: 'e.g. Tech Startup Inc.'),
            _field('About', _aboutCtrl, hint: 'Tell people about yourself...', maxLines: 4),
            const SizedBox(height: 24),
            Consumer<ProfileProvider>(
              builder: (_, pp, __) => MinaButton(label: 'Save Changes', onPressed: _save, isLoading: pp.isLoading),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {String? hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(controller: ctrl, maxLines: maxLines, decoration: InputDecoration(hintText: hint ?? label)),
        const SizedBox(height: 16),
      ],
    );
  }
}
