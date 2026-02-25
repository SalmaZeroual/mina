import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessageRemoteDataSource {
  final ApiClient _client;
  const MessageRemoteDataSource(this._client);

  Future<List<ConversationModel>> getConversations() async {
    try {
      final res = await _client.get(ApiEndpoints.conversations);
      return (res.data['data'] as List)
          .map((e) => ConversationModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<ConversationModel> startConversation({required String userId}) async {
    try {
      final res = await _client.post(
        ApiEndpoints.createConversation,
        data: {'user_id': userId},
      );
      return ConversationModel.fromJson(res.data['data']);
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<List<MessageModel>> getMessages({
    required String conversationId,
    int page = 1,
  }) async {
    try {
      final res = await _client.get(
        ApiEndpoints.messages(conversationId),
        queryParameters: {'page': page},
      );
      return (res.data['data'] as List)
          .map((e) => MessageModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final res = await _client.post(
        ApiEndpoints.sendMessage(conversationId),
        data: {'content': content},
      );
      return MessageModel.fromJson(res.data['data']);
    } catch (e) {
      throw ServerException(_parse(e));
    }
  }

  String _parse(dynamic e) {
    try {
      return (e as dynamic).response?.data['error'] ?? 'Erreur réseau';
    } catch (_) {
      return 'Erreur réseau';
    }
  }
}