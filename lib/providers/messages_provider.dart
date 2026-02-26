import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';

class MessagesProvider extends ChangeNotifier {
  final MessageService _service = MessageService();
  List<ConversationModel> _conversations = [];
  List<MessageModel> _currentMessages = [];
  bool _isLoading = false;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

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
    _isLoading = true;
    notifyListeners();
    try {
      _currentMessages = await _service.getMessages(conversationId);
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
      notifyListeners();
    } catch (_) {}
  }
}