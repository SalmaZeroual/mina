import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/user_avatar.dart';
import '../providers/chat_provider.dart';
import '../providers/messages_state.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String? otherUserAvatar;
  const ChatScreen({super.key, required this.conversationId, required this.otherUserName, this.otherUserAvatar});

  @override ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _typing  = false;

  @override
  void initState() {
    super.initState();
    ref.read(chatProvider(widget.conversationId).notifier).init();
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    ref.read(chatProvider(widget.conversationId).notifier).send(text);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state  = ref.watch(chatProvider(widget.conversationId));
    final authSt = ref.watch(authProvider);
    final myId   = authSt is AuthAuthenticated ? authSt.user.id : '';

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          UserAvatar(name: widget.otherUserName, avatarUrl: widget.otherUserAvatar, size: 34),
          const SizedBox(width: 10),
          Text(widget.otherUserName, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
      ),
      body: Column(children: [
        Expanded(child: switch (state) {
          ChatLoading() => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ChatError(:final message) => Center(child: Text(message, style: const TextStyle(color: AppColors.greyMuted))),
          ChatLoaded(:final messages, :final someoneTyping, :final typingName) => Column(children: [
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final msg  = messages[i];
                  final isMe = msg.senderId == myId;
                  return _Bubble(
                    content: msg.content,
                    isMe: isMe,
                    senderName: msg.senderName,
                    createdAt: msg.createdAt,
                  );
                },
              ),
            ),
            if (someoneTyping)
              Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('$typingName est en train d\'écrire...',
                    style: const TextStyle(color: AppColors.greyMuted, fontSize: 12, fontStyle: FontStyle.italic)),
                ),
              ),
          ]),
          _ => const SizedBox(),
        }),

        // Input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'Message...', border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onChanged: (v) {
                  final isTyping = v.isNotEmpty;
                  if (isTyping != _typing) {
                    _typing = isTyping;
                    if (_typing) ref.read(chatProvider(widget.conversationId).notifier).startTyping();
                    else         ref.read(chatProvider(widget.conversationId).notifier).stopTyping();
                  }
                },
                onSubmitted: (_) => _send(),
              ),
            ),
            GestureDetector(
              onTap: _send,
              child: Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: AppColors.white, size: 18),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final String senderName;
  final DateTime createdAt;
  const _Bubble({required this.content, required this.isMe, required this.senderName, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(14),
            topRight:    const Radius.circular(14),
            bottomLeft:  Radius.circular(isMe ? 14 : 3),
            bottomRight: Radius.circular(isMe ? 3  : 14),
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(content, style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.4)),
          const SizedBox(height: 4),
          Text(_fmt(createdAt),
            style: TextStyle(
              fontSize: 10,
              color: isMe ? AppColors.white.withOpacity(.6) : AppColors.greyMuted)),
        ]),
      ),
    );
  }

  String _fmt(DateTime dt) {
    return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }
}