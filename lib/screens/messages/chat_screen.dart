import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../models/message_model.dart';
import '../../providers/messages_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/avatar_widget.dart';
import '../../config/constants.dart';

class ChatScreen extends StatefulWidget {
  final ConversationModel conversation;
  const ChatScreen({super.key, required this.conversation});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();
  bool _isComposing = false;
  MessageModel? _replyingTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesProvider>().loadMessages(widget.conversation.id);
    });
    _messageCtrl.addListener(() {
      final composing = _messageCtrl.text.trim().isNotEmpty;
      if (composing != _isComposing) setState(() => _isComposing = composing);
      if (composing) context.read<MessagesProvider>().onTyping(widget.conversation.id);
    });
  }

  @override
  void dispose() {
    context.read<MessagesProvider>().clearCurrentMessages();
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageCtrl.text.trim();
    if (content.isEmpty) return;
    _messageCtrl.clear();
    final replyId = _replyingTo?.id;
    setState(() { _isComposing = false; _replyingTo = null; });
    context.read<MessagesProvider>().stopTyping(widget.conversation.id);
    await context.read<MessagesProvider>().sendMessage(widget.conversation.id, content, replyToId: replyId);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _sendImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1200);
      if (picked == null || !mounted) return;
      await context.read<MessagesProvider>().sendImage(widget.conversation.id, File(picked.path));
      _scrollToBottom();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _deleteConversation() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer la conversation'),
        content: const Text('Tous les messages seront supprimés définitivement.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<MessagesProvider>().deleteConversation(widget.conversation.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _blockUser() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Bloquer ${widget.conversation.participant.fullName}'),
        content: const Text('Cette personne ne pourra plus vous envoyer de messages.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Bloquer', style: TextStyle(color: Colors.orange))),
        ],
      ),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Utilisateur bloqué'), behavior: SnackBarBehavior.floating));
      Navigator.pop(context);
    }
  }

  void _onMessageLongPress(MessageModel msg) {
    HapticFeedback.mediumImpact();
    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageActionsSheet(
        message: msg,
        isMe: msg.senderId == currentUserId,
        onReply: () { setState(() => _replyingTo = msg); _focusNode.requestFocus(); },
        onCopy: () {
          if (msg.content.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: msg.content));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Message copié'), behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1)));
          }
        },
        onDelete: () async {
          await context.read<MessagesProvider>().deleteMessage(widget.conversation.id, msg.id);
        },
        onReact: (emoji) {
          context.read<MessagesProvider>().reactToMessage(widget.conversation.id, msg.id, emoji);
        },
      ),
    );
  }

  void _showAttachSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _attachTile(Icons.photo_library_rounded, 'Galerie',
                  () { Navigator.pop(context); _sendImage(ImageSource.gallery); }),
              _attachTile(Icons.camera_alt_rounded, 'Caméra',
                  () { Navigator.pop(context); _sendImage(ImageSource.camera); }),
            ]),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _attachTile(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, color: AppTheme.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.conversation.participant;
    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {},
          child: Row(children: [
            Stack(children: [
              AvatarWidget(initials: p.initials, size: 38, avatarUrl: p.avatarUrl),
              if (p.isOnline)
                Positioned(right: 0, bottom: 0, child: Container(
                  width: 11, height: 11,
                  decoration: BoxDecoration(color: AppTheme.success, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                )),
            ]),
            const SizedBox(width: 10),
            Consumer<MessagesProvider>(
              builder: (_, mp, __) {
                final conv = mp.conversations.firstWhere(
                  (c) => c.id == widget.conversation.id, orElse: () => widget.conversation);
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.fullName, style: const TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  conv.isTyping
                      ? const Text('en train d\'écrire...',
                          style: TextStyle(fontSize: 11, color: AppTheme.primary,
                              fontStyle: FontStyle.italic, fontWeight: FontWeight.normal))
                      : Text(p.isOnline ? '🟢 Active now' : p.title,
                          style: TextStyle(fontSize: 11,
                              color: p.isOnline ? AppTheme.success : AppTheme.textSecondary,
                              fontWeight: FontWeight.normal)),
                ]);
              },
            ),
          ]),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: AppTheme.textPrimary, size: 22),
            onPressed: () => _showComingSoon('Appel vidéo'),
          ),
          IconButton(
            icon: const Icon(Icons.phone_outlined, color: AppTheme.textPrimary, size: 20),
            onPressed: () => _showComingSoon('Appel vocal'),
          ),
          PopupMenuButton<void>(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary, size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => <PopupMenuEntry<void>>[
              _menuItem(Icons.person_outline, 'Voir le profil', () {}),
              _menuItem(Icons.photo_library_outlined, 'Envoyer une photo',
                  () => _sendImage(ImageSource.gallery)),
              _menuItem(Icons.camera_alt_outlined, 'Prendre une photo',
                  () => _sendImage(ImageSource.camera)),
              _menuItem(Icons.notifications_off_outlined, 'Désactiver les notifications',
                  () => _showComingSoon('Notifications')),
              const PopupMenuDivider(),
              _menuItem(Icons.block, 'Bloquer', _blockUser, color: Colors.orange),
              _menuItem(Icons.delete_outline, 'Supprimer la conversation',
                  _deleteConversation, color: Colors.red),
            ],
          ),
        ],
      ),

      body: Column(children: [
        Expanded(
          child: Consumer<MessagesProvider>(
            builder: (_, mp, __) {
              if (mp.isLoading && mp.currentMessages.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
              }
              if (mp.currentMessages.isEmpty) return _ConversationStart(participant: p);
              WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
              return ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                itemCount: mp.currentMessages.length,
                itemBuilder: (_, i) {
                  final msg = mp.currentMessages[i];
                  final prevMsg = i > 0 ? mp.currentMessages[i - 1] : null;
                  final isMe = msg.senderId == currentUserId;
                  final showTimestamp = prevMsg == null ||
                      msg.sentAt.difference(prevMsg.sentAt).inMinutes > 10;
                  return Column(children: [
                    if (showTimestamp) _TimestampDivider(time: msg.sentAt),
                    _MessageBubble(message: msg, isMe: isMe,
                        onLongPress: () => _onMessageLongPress(msg)),
                  ]);
                },
              );
            },
          ),
        ),
        if (_replyingTo != null)
          _ReplyBar(message: _replyingTo!, onCancel: () => setState(() => _replyingTo = null)),
        _InputBar(controller: _messageCtrl, focusNode: _focusNode,
            isComposing: _isComposing, onSend: _sendMessage, onAttach: _showAttachSheet),
      ]),
    );
  }

  PopupMenuItem<void> _menuItem(IconData icon, String label, VoidCallback onTap, {Color? color}) =>
      PopupMenuItem<void>(
        onTap: onTap,
        child: Row(children: [
          Icon(icon, size: 18, color: color ?? AppTheme.textPrimary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color ?? AppTheme.textPrimary, fontSize: 14)),
        ]),
      );

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$feature — bientôt disponible 🚀'),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback onLongPress;
  const _MessageBubble({required this.message, required this.isMe, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return Padding(
        padding: EdgeInsets.only(bottom: 4, left: isMe ? 60 : 0, right: isMe ? 0 : 60),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(18)),
            child: Text('🗑 Message supprimé',
                style: TextStyle(color: Colors.grey[500], fontSize: 13, fontStyle: FontStyle.italic)),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 4, left: isMe ? 60 : 0, right: isMe ? 0 : 60),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.replyToContent != null) _ReplyPreview(message: message, isMe: isMe),
              Container(
                decoration: BoxDecoration(
                  color: isMe ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (message.type == MessageType.image && message.mediaUrl != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18), topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4),
                      ),
                      child: Image.network(
                        '${AppConstants.apiBaseUrl.replaceAll('/v1', '')}${message.mediaUrl}',
                        width: 220, fit: BoxFit.cover,
                        loadingBuilder: (_, child, p) => p == null ? child :
                            Container(width: 220, height: 160, color: Colors.grey[200],
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        errorBuilder: (_, __, ___) => Container(width: 220, height: 120,
                            color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    )
                  else if (message.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                      child: Text(message.content,
                          style: TextStyle(color: isMe ? Colors.white : AppTheme.textPrimary,
                              fontSize: 14, height: 1.4)),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 2, 10, 8),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(message.timeLabel,
                          style: TextStyle(fontSize: 10,
                              color: isMe ? Colors.white.withOpacity(0.65) : AppTheme.textSecondary)),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(message.isRead ? Icons.done_all : Icons.done, size: 13,
                            color: message.isRead ? Colors.lightBlueAccent : Colors.white.withOpacity(0.65)),
                      ],
                    ]),
                  ),
                ]),
              ),
              if (message.reactions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(spacing: 4,
                    children: message.reactions.entries.where((e) => e.value.isNotEmpty).map((e) =>
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
                        child: Text('${e.key} ${e.value.length}', style: const TextStyle(fontSize: 12)),
                      )
                    ).toList()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  const _ReplyPreview({required this.message, required this.isMe});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
    decoration: BoxDecoration(
      color: isMe ? Colors.white.withOpacity(0.15) : Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      border: const Border(left: BorderSide(color: AppTheme.primary, width: 3)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(message.replyToSender ?? '',
          style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w700)),
      const SizedBox(height: 2),
      Text(message.replyToContent ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12,
              color: isMe ? Colors.white.withOpacity(0.7) : AppTheme.textSecondary)),
    ]),
  );
}

class _TimestampDivider extends StatelessWidget {
  final DateTime time;
  const _TimestampDivider({required this.time});
  String get _label {
    final diff = DateTime.now().difference(time);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.day}/${time.month}/${time.year}';
  }
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      const Expanded(child: Divider()),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(_label, style: const TextStyle(color: AppTheme.textSecondary,
              fontSize: 11, fontWeight: FontWeight.w500))),
      const Expanded(child: Divider()),
    ]),
  );
}

class _ConversationStart extends StatelessWidget {
  final ParticipantModel participant;
  const _ConversationStart({required this.participant});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AvatarWidget(initials: participant.initials, size: 72, avatarUrl: participant.avatarUrl),
        const SizedBox(height: 16),
        Text(participant.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        if (participant.title.isNotEmpty)
          Text(participant.title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20)),
          child: const Text('Start your conversation 👋',
              style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ]),
    ),
  );
}

class _ReplyBar extends StatelessWidget {
  final MessageModel message;
  final VoidCallback onCancel;
  const _ReplyBar({required this.message, required this.onCancel});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    color: const Color(0xFFF0F2F5),
    child: Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
          border: const Border(left: BorderSide(color: AppTheme.primary, width: 3))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Replying to ${message.senderName}',
              style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(message.type == MessageType.image ? '📷 Photo' : message.content,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ])),
        IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onCancel),
      ]),
    ),
  );
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isComposing;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  const _InputBar({required this.controller, required this.focusNode,
      required this.isComposing, required this.onSend, required this.onAttach});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
    decoration: BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
    child: SafeArea(top: false, child: Row(children: [
      GestureDetector(
        onTap: onAttach,
        child: Container(width: 38, height: 38,
            decoration: const BoxDecoration(color: Color(0xFFF0F1F5), shape: BoxShape.circle),
            child: const Icon(Icons.add_rounded, color: AppTheme.textSecondary, size: 20)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 120),
          decoration: BoxDecoration(color: const Color(0xFFF0F1F5), borderRadius: BorderRadius.circular(22)),
          child: TextField(
            controller: controller, focusNode: focusNode, maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Message...', hintStyle: TextStyle(color: AppTheme.textSecondary),
              border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onSubmitted: (_) => onSend(),
          ),
        ),
      ),
      const SizedBox(width: 8),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
        child: isComposing
            ? GestureDetector(key: const ValueKey('send'), onTap: onSend,
                child: Container(width: 42, height: 42,
                    decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)))
            : GestureDetector(key: const ValueKey('emoji'), onTap: () {},
                child: Container(width: 42, height: 42,
                    decoration: const BoxDecoration(color: Color(0xFFF0F1F5), shape: BoxShape.circle),
                    child: const Icon(Icons.emoji_emotions_outlined, color: AppTheme.textSecondary, size: 22))),
      ),
    ])),
  );
}

class _MessageActionsSheet extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback onReply;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final Function(String) onReact;
  const _MessageActionsSheet({required this.message, required this.isMe,
      required this.onReply, required this.onCopy, required this.onDelete, required this.onReact});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 12),
      Container(
        width: double.infinity, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(10)),
        child: Text(message.type == MessageType.image ? '📷 Photo' : message.content,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['👍', '❤️', '😂', '😮', '😢', '🔥'].map((e) =>
          GestureDetector(
            onTap: () { Navigator.pop(context); onReact(e); },
            child: Text(e, style: const TextStyle(fontSize: 28)),
          )).toList(),
      ),
      const SizedBox(height: 16),
      const Divider(height: 1),
      _action(context, Icons.reply_outlined, 'Répondre', onReply),
      if (message.type == MessageType.text)
        _action(context, Icons.copy_outlined, 'Copier', onCopy),
      _action(context, Icons.forward_outlined, 'Transférer', () => Navigator.pop(context)),
      if (isMe)
        _action(context, Icons.delete_outline, 'Supprimer', () {
          Navigator.pop(context);
          onDelete();
        }, color: Colors.red),
    ]),
  );

  Widget _action(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) =>
      ListTile(
        leading: Icon(icon, color: color ?? AppTheme.textPrimary, size: 20),
        title: Text(label, style: TextStyle(color: color ?? AppTheme.textPrimary, fontSize: 15)),
        onTap: () { Navigator.pop(context); onTap(); },
        dense: true, contentPadding: EdgeInsets.zero,
      );
}