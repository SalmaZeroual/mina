import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings',
            style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: ListView(children: [

        // ── Profile header ─────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(user?.initials ?? '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(user?.fullName ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0F172A))),
              if (user?.title.isNotEmpty == true) ...[
                const SizedBox(height: 2),
                Text(user!.title,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ],
              const SizedBox(height: 4),
              Text(user?.email ?? '',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ])),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Edit',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
              ),
            ),
          ]),
        ),

        // ── Account ────────────────────────────────────────────────────
        _Header('Account'),
        _Group(children: [
          _Tile(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profile',
            sub: 'Name, title, bio, location',
            onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
          ),
          _Tile(
            icon: Icons.grid_view_rounded,
            label: 'Cell / Domain',
            sub: user?.cell.isNotEmpty == true ? user!.cell : 'Not set',
            onTap: () => Navigator.pushNamed(context, AppRoutes.selectCell),
          ),
          _Tile(
            icon: Icons.lock_outline_rounded,
            label: 'Change Password',
            onTap: () => _showChangePassword(context),
          ),
        ]),

        // ── Privacy ─────────────────────────────────────────────────────
        _Header('Privacy & Notifications'),
        _Group(children: [
          _Tile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            sub: 'Manage your alerts',
            onTap: () => _showNotifications(context),
          ),
          _Tile(
            icon: Icons.visibility_outlined,
            label: 'Profile Visibility',
            sub: 'Public · visible to your cell',
            onTap: () {},
          ),
          _Tile(
            icon: Icons.block_rounded,
            label: 'Blocked Users',
            onTap: () {},
          ),
        ]),

        // ── Content ─────────────────────────────────────────────────────
        _Header('My Content'),
        _Group(children: [
          _Tile(
            icon: Icons.article_outlined,
            label: 'My Posts',
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          _Tile(
            icon: Icons.handyman_outlined,
            label: 'My Services',
            onTap: () => Navigator.pushNamed(context, AppRoutes.services),
          ),
          _Tile(
            icon: Icons.group_outlined,
            label: 'My Communities',
            onTap: () => Navigator.pushNamed(context, AppRoutes.groups),
          ),
        ]),

        // ── Support ─────────────────────────────────────────────────────
        _Header('Support'),
        _Group(children: [
          _Tile(
            icon: Icons.help_outline_rounded,
            label: 'Help Center',
            onTap: () {},
          ),
          _Tile(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () {},
          ),
          _Tile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {},
          ),
          _Tile(
            icon: Icons.info_outline_rounded,
            label: 'About Mina',
            sub: 'Version 1.0.0',
            onTap: () => _showAbout(context),
          ),
        ]),

        // ── Danger zone ─────────────────────────────────────────────────
        _Header('Account Management'),
        _Group(children: [
          _Tile(
            icon: Icons.logout_rounded,
            label: 'Log Out',
            labelColor: AppTheme.primary,
            iconColor: AppTheme.primary,
            onTap: () => _confirmLogout(context),
            showChevron: false,
          ),
          _Tile(
            icon: Icons.delete_forever_rounded,
            label: 'Delete Account',
            sub: 'Permanently delete all your data',
            labelColor: Colors.red.shade600,
            iconColor: Colors.red.shade600,
            onTap: () => _confirmDelete(context),
            showChevron: false,
          ),
        ]),

        const SizedBox(height: 40),
        Center(
          child: Column(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.hub_rounded,
                  size: 18, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            const Text('Mina',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF374151))),
            const SizedBox(height: 2),
            Text('Professional Network · v1.0.0',
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary.withOpacity(0.6))),
          ]),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  // ── Sheets & dialogs ───────────────────────────────────────────────────────
  void _showChangePassword(BuildContext context) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _ChangePasswordSheet(),
      );

  void _showNotifications(BuildContext context) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _NotificationsSheet(),
      );

  void _showAbout(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(28),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 68, height: 68,
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFFFF6B8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20)),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 16),
        const Text('Mina',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Version 1.0.0',
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        const Text(
          'The professional network built for cell-based communities. '
          'Connect, collaborate and grow with experts in your field.',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.6),
        ),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
      ],
    ),
  );

  void _confirmLogout(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Log out?'),
      content: const Text('You will need to sign in again to access your account.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (_) => false);
            }
          },
          child: const Text('Log out',
              style: TextStyle(color: AppTheme.primary,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  void _confirmDelete(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Delete account?'),
      content: const Text(
        'All your posts, services, communities and data will be '
        'permanently deleted. This cannot be undone.',
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Delete',
              style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable settings widgets
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String label;
  const _Header(this.label);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
    child: Text(label.toUpperCase(),
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: AppTheme.textSecondary.withOpacity(0.65))),
  );
}

class _Group extends StatelessWidget {
  final List<Widget> children;
  const _Group({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECF2))),
    child: Column(children: [
      for (int i = 0; i < children.length; i++) ...[
        children[i],
        if (i < children.length - 1)
          const Divider(height: 1, indent: 56, endIndent: 0,
              color: Color(0xFFF1F5F9)),
      ],
    ]),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sub;
  final Color? labelColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showChevron;

  const _Tile({
    required this.icon,
    required this.label,
    this.sub,
    this.labelColor,
    this.iconColor,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: (iconColor ?? AppTheme.primary).withOpacity(0.09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18,
              color: iconColor ?? AppTheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? const Color(0xFF0F172A))),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ])),
        if (showChevron)
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFCBD5E1), size: 20),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Change password sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();
  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _curCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _cfmCtrl = TextEditingController();
  bool _o1 = true, _o2 = true, _o3 = true;
  bool _saving = false;

  @override
  void dispose() {
    _curCtrl.dispose(); _newCtrl.dispose(); _cfmCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_newCtrl.text.length < 6) {
      _snack(context, 'Password must be at least 6 characters', isError: true);
      return;
    }
    if (_newCtrl.text != _cfmCtrl.text) {
      _snack(context, 'Passwords do not match', isError: true);
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.pop(context);
      _snack(context, '✅ Password updated successfully');
    }
  }

  void _snack(BuildContext ctx, String msg, {bool isError = false}) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));

  @override
  Widget build(BuildContext context) => _Sheet(
    title: 'Change Password',
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      _PwField(ctrl: _curCtrl, label: 'Current password',
          obscure: _o1, onToggle: () => setState(() => _o1 = !_o1)),
      const SizedBox(height: 12),
      _PwField(ctrl: _newCtrl, label: 'New password',
          obscure: _o2, onToggle: () => setState(() => _o2 = !_o2)),
      const SizedBox(height: 12),
      _PwField(ctrl: _cfmCtrl, label: 'Confirm new password',
          obscure: _o3, onToggle: () => setState(() => _o3 = !_o3)),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Text('Update Password',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ),
      ),
    ]),
  );
}

class _PwField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  const _PwField({required this.ctrl, required this.label,
      required this.obscure, required this.onToggle});
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    obscureText: obscure,
    decoration: InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 18),
        onPressed: onToggle,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications sheet
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();
  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _posts = true;
  bool _follows = true;
  bool _groups = true;
  bool _messages = true;
  bool _services = false;

  @override
  Widget build(BuildContext context) => _Sheet(
    title: 'Notifications',
    subtitle: 'Choose what you want to be notified about',
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      _NSwitch(
          icon: Icons.article_outlined,
          title: 'Post activity',
          sub: 'Likes & comments on your posts',
          value: _posts,
          onChange: (v) => setState(() => _posts = v)),
      _NSwitch(
          icon: Icons.person_add_outlined,
          title: 'New followers',
          sub: 'When someone follows you',
          value: _follows,
          onChange: (v) => setState(() => _follows = v)),
      _NSwitch(
          icon: Icons.group_outlined,
          title: 'Community updates',
          sub: 'New posts in your groups',
          value: _groups,
          onChange: (v) => setState(() => _groups = v)),
      _NSwitch(
          icon: Icons.chat_bubble_outline,
          title: 'Messages',
          sub: 'New direct messages',
          value: _messages,
          onChange: (v) => setState(() => _messages = v)),
      _NSwitch(
          icon: Icons.handyman_outlined,
          title: 'Service inquiries',
          sub: 'Requests about your services',
          value: _services,
          onChange: (v) => setState(() => _services = v)),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity, height: 50,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('✅ Preferences saved'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ));
          },
          child: const Text('Save Preferences',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    ]),
  );
}

class _NSwitch extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final bool value;
  final ValueChanged<bool> onChange;
  const _NSwitch({required this.icon, required this.title, required this.sub,
      required this.value, required this.onChange});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 17, color: AppTheme.primary),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(sub,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      value: value,
      onChanged: onChange,
      activeColor: AppTheme.primary,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic bottom sheet wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _Sheet extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _Sheet({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    padding: EdgeInsets.fromLTRB(
        24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 28),
    child: Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(child: Container(
        width: 40, height: 4,
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2)),
      )),
      const SizedBox(height: 20),
      Text(title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A))),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle!,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
      ],
      const SizedBox(height: 20),
      child,
    ]),
  );
}