import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/message_service.dart';

class MessagesProvider extends ChangeNotifier {
  final MessageService _service = MessageService();

  List<ConversationModel> _conversations = [];
  List<MessageModel> _currentMessages = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSending = false;
  String? _activeConversationId;
  Timer? _typingTimer;
  Timer? _pollTimer;

  // ─── Getters ────────────────────────────────────────────────────────────────
  List<ConversationModel> get conversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations.where((c) =>
        c.participant.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        c.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  List<ConversationModel> get friendConversations =>
      conversations.where((c) => !c.isService).toList();

  List<ConversationModel> get serviceConversations =>
      conversations.where((c) => c.isService).toList();

  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  int get totalUnread => _conversations.fold(0, (sum, c) => sum + c.unreadCount);
  String? get activeConversationId => _activeConversationId;

  List<UserModel> _userResults = [];
  List<UserModel> get userResults => _userResults;

  // ─── Search ──────────────────────────────────────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) { _userResults = []; notifyListeners(); return; }
    try {
      _userResults = await UserService().searchUsers(query);
    } catch (_) { _userResults = []; }
    notifyListeners();
  }

  // ─── Conversations ───────────────────────────────────────────────────────────
  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();
    try {
      _conversations = await _service.getConversations();
    } catch (_) { _conversations = []; }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await _service.deleteConversation(conversationId);
      _conversations.removeWhere((c) => c.id == conversationId);
      if (_activeConversationId == conversationId) {
        _activeConversationId = null;
        _currentMessages = [];
      }
      notifyListeners();
    } catch (_) {}
  }

  // ─── Messages ────────────────────────────────────────────────────────────────
  Future<void> loadMessages(String conversationId) async {
    _activeConversationId = conversationId;
    _isLoading = true;
    _currentMessages = [];
    notifyListeners();
    try {
      _currentMessages = await _service.getMessages(conversationId);
      _markConversationRead(conversationId);
      _startPolling(conversationId);
    } catch (_) { _currentMessages = []; }
    _isLoading = false;
    notifyListeners();
  }

  void _markConversationRead(String conversationId) {
    _conversations = _conversations.map((c) {
      if (c.id == conversationId) return c.copyWith(unreadCount: 0);
      return c;
    }).toList();
    _service.markRead(conversationId);
  }

  // Poll for new messages + typing every 2s while in chat
  void _startPolling(String conversationId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_activeConversationId != conversationId) { _pollTimer?.cancel(); return; }
      try {
        final messages = await _service.getMessages(conversationId);
        final isTyping = await _service.getTyping(conversationId);

        // Add only new messages
        final existingIds = _currentMessages.map((m) => m.id).toSet();
        final newMsgs = messages.where((m) => !existingIds.contains(m.id)).toList();
        if (newMsgs.isNotEmpty || _hasChanges(messages)) {
          _currentMessages = messages;
          notifyListeners();
        }

        // Update typing in conversation list
        _conversations = _conversations.map((c) {
          if (c.id == conversationId) return c.copyWith(isTyping: isTyping);
          return c;
        }).toList();

        if (newMsgs.isNotEmpty) {
          _updateConvLastMessage(conversationId, messages.last);
          notifyListeners();
        }
      } catch (_) {}
    });
  }

  bool _hasChanges(List<MessageModel> fresh) {
    if (fresh.length != _currentMessages.length) return true;
    for (int i = 0; i < fresh.length; i++) {
      if (fresh[i].isRead != _currentMessages[i].isRead) return true;
      if (fresh[i].reactions.length != _currentMessages[i].reactions.length) return true;
    }
    return false;
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ─── Send text ───────────────────────────────────────────────────────────────
  Future<void> sendMessage(String conversationId, String content, {String? replyToId}) async {
    _isSending = true;
    notifyListeners();
    try {
      final msg = await _service.sendMessage(conversationId, content, replyToId: replyToId);
      _currentMessages.add(msg);
      _updateConvLastMessage(conversationId, msg);
      notifyListeners();
    } catch (_) {}
    _isSending = false;
    notifyListeners();
  }

  // ─── Send image ──────────────────────────────────────────────────────────────
  Future<void> sendImage(String conversationId, File file) async {
    _isSending = true;
    notifyListeners();
    try {
      final msg = await _service.sendImage(conversationId, file);
      _currentMessages.add(msg);
      _updateConvLastMessage(conversationId, msg);
      notifyListeners();
    } catch (_) {}
    _isSending = false;
    notifyListeners();
  }

  // ─── Delete message ───────────────────────────────────────────────────────────
  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      await _service.deleteMessage(conversationId, messageId);
      _currentMessages.removeWhere((m) => m.id == messageId);
      notifyListeners();
    } catch (_) {}
  }

  // ─── React to message ─────────────────────────────────────────────────────────
  Future<void> reactToMessage(String conversationId, String messageId, String emoji) async {
    try {
      final newReactions = await _service.reactToMessage(conversationId, messageId, emoji);
      _currentMessages = _currentMessages.map((m) {
        if (m.id == messageId) return m.copyWith(reactions: newReactions);
        return m;
      }).toList();
      notifyListeners();
    } catch (_) {}
  }

  // ─── Typing ──────────────────────────────────────────────────────────────────
  void onTyping(String conversationId) {
    _service.setTyping(conversationId, true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      _service.setTyping(conversationId, false);
    });
  }

  void stopTyping(String conversationId) {
    _typingTimer?.cancel();
    _service.setTyping(conversationId, false);
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────
  void _updateConvLastMessage(String conversationId, MessageModel msg) {
    final display = msg.type == MessageType.image ? '📷 Photo' : msg.content;
    _conversations = _conversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(lastMessage: display, lastMessageAt: msg.sentAt, unreadCount: 0);
      }
      return c;
    }).toList();
    _conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  }

  void clearCurrentMessages() {
    stopPolling();
    stopTyping(_activeConversationId ?? '');
    _currentMessages = [];
    _activeConversationId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }
}