import 'api_service.dart';
import '../models/message_model.dart';

class MessageService {
  Future<List<ConversationModel>> getConversations() async {
    final data = await ApiService.get('/messages');
    return (data['data'] as List).map((j) => ConversationModel.fromJson(j)).toList();
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final data = await ApiService.get('/messages/$conversationId');
    return (data['data'] as List).map((j) => MessageModel.fromJson(j)).toList();
  }

  Future<MessageModel> sendMessage(String conversationId, String content) async {
    final data = await ApiService.post('/messages/$conversationId', {'content': content});
    return MessageModel.fromJson(data['data']);
  }

  Future<ConversationModel> getOrCreateConversation(String userId, {String? serviceId}) async {
    final data = await ApiService.post('/messages/with/$userId',
        serviceId != null ? {'service_id': serviceId} : {});
    return ConversationModel.fromJson(data['data']);
  }
}