import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

class MessagesProvider extends ChangeNotifier {
  final MessageService _service = MessageService();
  List<ConversationModel> _conversations = [];
  List<MessageModel> _currentMessages = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _activeConversationId;

  List<ConversationModel> get conversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations.where((c) =>
      c.participant.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      c.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  int get totalUnread => _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();
    try {
      _conversations = await _service.getConversations();
    } catch (_) {
      _conversations = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages(String conversationId) async {
    _activeConversationId = conversationId;
    _isLoading = true;
    _currentMessages = [];
    notifyListeners();
    try {
      _currentMessages = await _service.getMessages(conversationId);
      // Mark as read locally
      _conversations = _conversations.map((c) {
        if (c.id == conversationId) {
          return ConversationModel(
            id: c.id, participant: c.participant,
            lastMessage: c.lastMessage, lastMessageAt: c.lastMessageAt,
            unreadCount: 0,
          );
        }
        return c;
      }).toList();
    } catch (_) {
      _currentMessages = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String conversationId, String content) async {
    try {
      final msg = await _service.sendMessage(conversationId, content);
      _currentMessages.add(msg);
      // Update last message in conversation list
      _conversations = _conversations.map((c) {
        if (c.id == conversationId) {
          return ConversationModel(
            id: c.id, participant: c.participant,
            lastMessage: content, lastMessageAt: DateTime.now(),
            unreadCount: 0,
          );
        }
        return c;
      }).toList();
      // Sort by most recent
      _conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteConversation(String conversationId) async {
    _conversations.removeWhere((c) => c.id == conversationId);
    notifyListeners();
    // Backend delete would go here when endpoint is added
  }

  void clearCurrentMessages() {
    _currentMessages = [];
    _activeConversationId = null;
    notifyListeners();
  }
}