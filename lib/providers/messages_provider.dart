import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessagesProvider extends ChangeNotifier {
  List<ConversationModel> _conversations = [];
  List<MessageModel> _currentMessages = [];
  bool _isLoading = false;
  String? _currentConvId;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _conversations = ConversationModel.mocks;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages(String conversationId) async {
    _currentConvId = conversationId;
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _currentMessages = MessageModel.getMocksForConversation(conversationId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    final msg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'user_1',
      content: content,
      sentAt: DateTime.now(),
    );
    _currentMessages.add(msg);
    notifyListeners();
    // await ApiService.post('/messages', {'conversation_id': _currentConvId, 'content': content});
  }
}
