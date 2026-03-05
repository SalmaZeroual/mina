import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/messages_provider.dart';
import '../../models/message_model.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../config/routes.dart';
import '../../services/user_service.dart';
import '../../services/message_service.dart';
import '../../models/user_model.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<MessagesProvider>().loadConversations());
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(),
      body: Consumer<MessagesProvider>(
        builder: (_, mp, __) {
          if (mp.isLoading && mp.conversations.isEmpty) return const LoadingWidget();
          final convs = mp.conversations;

          return Column(children: [
            // Search bar (always visible)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              color: Colors.white,
              child: _SearchBar(
                controller: _searchCtrl,
                onChanged: (v) {
                  mp.search(v);
                  mp.searchUsers(v);
                  setState(() => _isSearching = v.isNotEmpty);
                },
                onClear: () {
                  _searchCtrl.clear();
                  mp.search('');
                  mp.searchUsers('');
                  setState(() => _isSearching = false);
                },
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: mp.loadConversations,
                color: AppTheme.primary,
                child: CustomScrollView(
                  slivers: [
                    // ── People from cell (when searching) ─────────────────
                    if (_isSearching && mp.userResults.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                          child: Text('People in your cell',
                              style: TextStyle(fontWeight: FontWeight.w700,
                                  fontSize: 12, color: AppTheme.textSecondary,
                                  letterSpacing: 0.5)),
                        ),
                      ),
                      SliverList(delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final u = mp.userResults[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                            leading: Stack(children: [
                              AvatarWidget(initials: u.initials,
                                  avatarUrl: u.avatarUrl, size: 46),
                              if (u.isOnline) Positioned(right: 1, bottom: 1,
                                child: Container(width: 10, height: 10,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2)),
                                )),
                            ]),
                            title: Text(u.fullName, style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                            subtitle: u.title.isNotEmpty
                                ? Text(u.title, style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF94A3B8)))
                                : null,
                            trailing: const Icon(Icons.send_rounded,
                                size: 18, color: AppTheme.primary),
                            onTap: () async {
                              try {
                                final conv = await MessageService()
                                    .getOrCreateConversation(u.id);
                                if (context.mounted) {
                                  Navigator.pushNamed(context,
                                      AppRoutes.chat, arguments: conv);
                                }
                              } catch (_) {}
                            },
                          );
                        },
                        childCount: mp.userResults.length,
                      )),
                      if (convs.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                            child: Text('Conversations',
                                style: TextStyle(fontWeight: FontWeight.w700,
                                    fontSize: 12, color: AppTheme.textSecondary,
                                    letterSpacing: 0.5)),
                          ),
                        ),
                    ],
                    // ── Conversations ─────────────────────────────────────
                    if (convs.isEmpty && !_isSearching)
                      SliverFillRemaining(
                        child: _EmptyState(
                            isSearching: _isSearching,
                            query: _searchCtrl.text),
                      )
                    else if (convs.isEmpty && _isSearching && mp.userResults.isEmpty)
                      SliverFillRemaining(
                        child: _EmptyState(
                            isSearching: true, query: _searchCtrl.text),
                      )
                    else
                      SliverList(delegate: SliverChildBuilderDelegate(
                        (_, i) => _ConversationTile(
                          conversation: convs[i],
                          onDelete: () => _confirmDelete(context, mp, convs[i]),
                        ),
                        childCount: convs.length,
                      )),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
            ),
          ]);
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      actions: [
        Consumer<MessagesProvider>(
          builder: (_, mp, __) => mp.totalUnread > 0
              ? Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text('${mp.totalUnread} unread',
                          style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppTheme.textPrimary),
          tooltip: 'New Message',
          onPressed: () => _showNewMessageSheet(context),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, MessagesProvider mp, ConversationModel conv) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          AvatarWidget(initials: conv.participant.initials, size: 56, avatarUrl: conv.participant.avatarUrl),
          const SizedBox(height: 12),
          Text('Delete conversation with', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(conv.participant.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 6),
          const Text('This will permanently remove all messages.\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel'),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                mp.deleteConversation(conv.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Conversation with ${conv.participant.fullName} deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  action: SnackBarAction(label: 'Undo', onPressed: () => mp.loadConversations(), textColor: Colors.white),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Delete'),
            )),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showNewMessageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewMessageSheet(),
    );
  }
}

// ─── Conversation Tile ───────────────────────────────────────────────────────
class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onDelete;
  const _ConversationTile({required this.conversation, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final conv = conversation;
    final hasUnread = conv.unreadCount > 0;

    return Dismissible(
      key: Key(conv.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false; // we handle it manually
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.withOpacity(0.1),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Icon(Icons.delete_outline, color: Colors.red, size: 26),
          SizedBox(height: 4),
          Text('Delete', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
      child: GestureDetector(
        onLongPress: onDelete,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: hasUnread ? Colors.white : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: hasUnread
                ? [BoxShadow(color: AppTheme.primary.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))]
                : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 1))],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => Navigator.pushNamed(context, AppRoutes.chat, arguments: conv),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(children: [
                  // Avatar with online dot
                  Stack(children: [
                    AvatarWidget(initials: conv.participant.initials, size: 50, avatarUrl: conv.participant.avatarUrl),
                    if (conv.participant.isOnline)
                      Positioned(right: 1, bottom: 1, child: Container(
                        width: 13, height: 13,
                        decoration: BoxDecoration(color: AppTheme.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      )),
                  ]),
                  const SizedBox(width: 13),

                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(
                        conv.participant.fullName,
                        style: TextStyle(
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 15, color: AppTheme.textPrimary,
                        ),
                      )),
                      Text(conv.timeAgo, style: TextStyle(
                        fontSize: 12,
                        color: hasUnread ? AppTheme.primary : AppTheme.textSecondary,
                        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                      )),
                    ]),
                    const SizedBox(height: 3),
                    if (conv.participant.title.isNotEmpty)
                      Text(conv.participant.title,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      Expanded(child: conv.isTyping
                          ? Row(children: [
                              const Text('typing', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontStyle: FontStyle.italic)),
                              const SizedBox(width: 4),
                              _TypingDots(),
                            ])
                          : Text(conv.lastMessage,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: hasUnread ? AppTheme.textPrimary : AppTheme.textSecondary,
                                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                              )),
                      ),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                          child: Text('${conv.unreadCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ]),
                  ])),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Typing animation ────────────────────────────────────────────────────────
class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(children: List.generate(3, (i) {
        final opacity = ((_ctrl.value * 3 - i) % 1.0).clamp(0.2, 1.0);
        return Container(
          margin: const EdgeInsets.only(right: 3),
          width: 4, height: 4,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      })),
    );
  }
}

// ─── Search Bar ──────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchBar({required this.controller, required this.onChanged, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(color: const Color(0xFFF0F1F5), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search messages or people...',
          hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.close, size: 16), onPressed: onClear)
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isSearching;
  final String query;
  const _EmptyState({required this.isSearching, required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(isSearching ? '🔍' : '💬', style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'No results for "$query"' : 'No conversations yet',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            isSearching
                ? 'Try a different name or keyword'
                : 'Connect with professionals in your cell.\nStart a conversation from someone\'s profile.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}

// ─── New Message Sheet ───────────────────────────────────────────────────────
class _NewMessageSheet extends StatefulWidget {
  const _NewMessageSheet();
  @override
  State<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<_NewMessageSheet> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _results = [];
  List<UserModel> _allUsers = [];
  bool _loading = true;
  bool _opening = false;
  String _openingId = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  // Load all users in my cell on open (no query needed)
  Future<void> _loadAll() async {
    try {
      final users = await UserService().searchUsers('');
      if (mounted) setState(() { _allUsers = users; _results = users; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String q) {
    final lower = q.toLowerCase().trim();
    setState(() {
      _results = lower.isEmpty
          ? _allUsers
          : _allUsers.where((u) =>
              u.fullName.toLowerCase().contains(lower) ||
              u.title.toLowerCase().contains(lower) ||
              u.cell.toLowerCase().contains(lower)).toList();
    });
  }

  Future<void> _openChat(BuildContext context, UserModel user) async {
    if (_opening) return;
    setState(() { _opening = true; _openingId = user.id; });
    try {
      final conv = await MessageService().getOrCreateConversation(user.id);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pushNamed(context, AppRoutes.chat, arguments: conv);
      }
    } catch (_) {}
    if (mounted) setState(() { _opening = false; _openingId = ''; });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(alignment: Alignment.centerLeft,
            child: Text('New Message',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 12),
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0))),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: _onSearch,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Search people in your cell...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 19, color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Results
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator(
                color: AppTheme.primary, strokeWidth: 2.5))
            : _results.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 52, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text(_searchCtrl.text.isEmpty
                              ? 'No people in your cell yet'
                              : 'No results for "${_searchCtrl.text}"',
                          style: const TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 14)),
                    ]))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    itemCount: _results.length,
                    itemBuilder: (_, i) {
                      final u = _results[i];
                      final isOpening = _opening && _openingId == u.id;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        leading: Stack(children: [
                          AvatarWidget(initials: u.initials,
                              avatarUrl: u.avatarUrl, size: 46),
                          if (u.isOnline) Positioned(right: 1, bottom: 1,
                            child: Container(width: 11, height: 11,
                              decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2)),
                            )),
                        ]),
                        title: Text(u.fullName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          if (u.title.isNotEmpty)
                            Text(u.title, style: const TextStyle(
                                fontSize: 12, color: Color(0xFF64748B))),
                          if (u.cell.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(u.cell, style: const TextStyle(
                                  fontSize: 10, color: AppTheme.primary,
                                  fontWeight: FontWeight.w700)),
                            ),
                        ]),
                        trailing: isOpening
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppTheme.primary))
                            : const Icon(Icons.send_rounded,
                                size: 20, color: AppTheme.primary),
                        onTap: () => _openChat(context, u),
                      );
                    },
                  )),
      ]),
    );
  }
}