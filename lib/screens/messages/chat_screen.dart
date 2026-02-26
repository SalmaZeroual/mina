import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/message_model.dart';
import '../../providers/messages_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/avatar_widget.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;
  const ChatScreen({super.key, required this.conversation});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<MessagesProvider>().loadMessages(widget.conversation.id));
  }

  @override
  void dispose() { _messageCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  void _sendMessage() async {
    if (_messageCtrl.text.trim().isEmpty) return;
    final content = _messageCtrl.text.trim();
    _messageCtrl.clear();
    await context.read<MessagesProvider>().sendMessage(widget.conversation.id, content);
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.conversation.participant;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(children: [
              AvatarWidget(initials: p.initials, size: 36),
              if (p.isOnline)
                Positioned(right: 0, bottom: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(color: AppTheme.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
            ]),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(p.isOnline ? 'Online' : p.title, style: TextStyle(fontSize: 12, color: p.isOnline ? AppTheme.success : AppTheme.textSecondary, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessagesProvider>(
              builder: (_, mp, __) {
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: mp.currentMessages.length,
                  itemBuilder: (_, i) => _MessageBubble(
                    message: mp.currentMessages[i],
                    currentUserId: context.read<AuthProvider>().currentUser?.id ?? '',
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppTheme.border))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final String currentUserId;
  const _MessageBubble({required this.message, required this.currentUserId});

  bool get isMe => message.senderId == currentUserId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? AppTheme.primary : AppTheme.inputFill,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          child: Text(
            message.content,
            style: TextStyle(color: isMe ? Colors.white : AppTheme.textPrimary, fontSize: 14),
          ),
        ),
      ),
    );
  }
}