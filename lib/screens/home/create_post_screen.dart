import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/avatar_widget.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentCtrl = TextEditingController();

  @override
  void dispose() { _contentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: const Text('Create Post'),
        actions: [
          Consumer<HomeProvider>(
            builder: (_, home, __) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: home.isPosting || _contentCtrl.text.isEmpty ? null : () async {
                  await home.createPost(_contentCtrl.text);
                  if (mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36), padding: const EdgeInsets.symmetric(horizontal: 16)),
                child: home.isPosting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Post'),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarWidget(initials: user?.initials ?? 'JD'),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _contentCtrl,
                    onChanged: (_) => setState(() {}),
                    maxLines: null,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Share something with your cell...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
