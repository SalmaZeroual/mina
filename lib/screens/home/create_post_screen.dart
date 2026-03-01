import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/avatar_widget.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _selectedAudience = 'Cell';
  bool _isComposing = false;

  static const _audiences = ['Cell', 'Everyone', 'Followers'];
  static const _quickTags = ['#Design', '#WebDev', '#OpenToWork', '#Hiring', '#Collab', '#Tip'];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() => _isComposing = _ctrl.text.trim().isNotEmpty));
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() { _ctrl.dispose(); _focus.dispose(); super.dispose(); }

  Future<void> _publish() async {
    final content = _ctrl.text.trim();
    if (content.isEmpty) return;
    HapticFeedback.mediumImpact();
    final success = await context.read<HomeProvider>().createPost(content);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18),
          SizedBox(width: 10),
          Text('Post published! 🎉'),
        ]),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ));
    } else {
      final error = context.read<HomeProvider>().error ?? 'Failed to publish';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $error'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          // Audience selector
          GestureDetector(
            onTap: _showAudiencePicker,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_audienceIcon, size: 13, color: AppTheme.primary),
                const SizedBox(width: 5),
                Text(_selectedAudience, style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                const Icon(Icons.keyboard_arrow_down, size: 14, color: AppTheme.primary),
              ]),
            ),
          ),
          Consumer<HomeProvider>(
            builder: (_, home, __) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AnimatedOpacity(
                opacity: _isComposing ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: (_isComposing && !home.isPosting) ? _publish : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.primary,
                    minimumSize: const Size(72, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: home.isPosting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Publish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        const Divider(height: 1),
        // Cell badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppTheme.surface,
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.grid_view_rounded, size: 12, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  user?.cell ?? 'Your Cell',
                  style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            Text('This post will be visible to your Cell members', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary.withOpacity(0.7))),
          ]),
        ),

        // Main compose area
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AvatarWidget(initials: user?.initials ?? 'JD', avatarUrl: user?.avatarUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(user?.fullName ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(user?.title ?? '', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        maxLines: null,
                        minLines: 6,
                        style: const TextStyle(fontSize: 16, height: 1.55, color: Color(0xFF1A1A2E)),
                        decoration: const InputDecoration(
                          hintText: "What's on your mind? Share with your Cell...",
                          hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Quick tags
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Quick Tags', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4, children: _quickTags.map((tag) => GestureDetector(
              onTap: () {
                final text = _ctrl.text;
                final newText = text.isEmpty ? tag : '$text $tag';
                _ctrl.text = newText;
                _ctrl.selection = TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(tag, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
              ),
            )).toList()),
          ]),
        ),

        // Bottom toolbar
        Container(
          padding: EdgeInsets.only(left: 8, right: 8, bottom: MediaQuery.of(context).viewInsets.bottom + 8, top: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: Row(children: [
            _ToolBtn(icon: Icons.image_outlined, label: 'Photo', onTap: () => _snack('Photo upload — coming soon')),
            _ToolBtn(icon: Icons.link, label: 'Link', onTap: () => _snack('Link preview — coming soon')),
            _ToolBtn(icon: Icons.poll_outlined, label: 'Poll', onTap: () => _snack('Polls — coming soon')),
            _ToolBtn(icon: Icons.emoji_emotions_outlined, label: 'Emoji', onTap: () {}),
            const Spacer(),
            Consumer<HomeProvider>(builder: (_, home, __) {
              final len = _ctrl.text.length;
              final max = 5000;
              return Text('$len/$max', style: TextStyle(
                fontSize: 12,
                color: len > max * 0.9 ? AppTheme.primary : AppTheme.textSecondary,
              ));
            }),
          ]),
        ),
      ]),
    );
  }

  IconData get _audienceIcon => switch (_selectedAudience) {
    'Cell' => Icons.grid_view_rounded,
    'Everyone' => Icons.public,
    _ => Icons.people_outline,
  };

  void _showAudiencePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Who can see this?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._audiences.map((a) => ListTile(
            leading: Icon(_audienceIconFor(a), color: _selectedAudience == a ? AppTheme.primary : AppTheme.textSecondary),
            title: Text(a, style: TextStyle(fontWeight: _selectedAudience == a ? FontWeight.bold : FontWeight.normal)),
            trailing: _selectedAudience == a ? const Icon(Icons.check, color: AppTheme.primary) : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: _selectedAudience == a ? AppTheme.primary.withOpacity(0.05) : null,
            onTap: () { setState(() => _selectedAudience = a); Navigator.pop(context); },
          )),
        ]),
      ),
    );
  }

  IconData _audienceIconFor(String a) => switch (a) {
    'Cell' => Icons.grid_view_rounded,
    'Everyone' => Icons.public,
    _ => Icons.people_outline,
  };

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _ToolBtn({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 22, color: AppTheme.textSecondary),
      ]),
    ),
  );
}