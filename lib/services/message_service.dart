import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/constants.dart';
import 'storage_service.dart';
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

  Future<MessageModel> sendMessage(String conversationId, String content,
      {String? replyToId}) async {
    final body = <String, dynamic>{'content': content};
    if (replyToId != null) body['reply_to_id'] = replyToId;
    final data = await ApiService.post('/messages/$conversationId', body);
    return MessageModel.fromJson(data['data']);
  }

  Future<MessageModel> sendImage(String conversationId, File file) async {
    final token = await StorageService.getToken();
    final uri = Uri.parse('${AppConstants.apiBaseUrl}/messages/$conversationId/image');
    final request = http.MultipartRequest('POST', uri);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    final ext = file.path.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'png' : ext == 'gif' ? 'gif' : 'jpeg';
    request.files.add(await http.MultipartFile.fromPath(
      'image', file.path,
      contentType: MediaType('image', mimeType),
    ));
    final streamed = await request.send();
    final respBody = await streamed.stream.bytesToString();
    final data = jsonDecode(respBody);
    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw ApiException(data['message'] ?? 'Upload failed', streamed.statusCode);
    }
    return MessageModel.fromJson(data['data']);
  }

  Future<void> deleteMessage(String conversationId, String messageId) async {
    await ApiService.delete('/messages/$conversationId/messages/$messageId');
  }

  Future<void> deleteConversation(String conversationId) async {
    await ApiService.delete('/messages/$conversationId');
  }

  Future<Map<String, List<String>>> reactToMessage(
      String conversationId, String messageId, String emoji) async {
    final data = await ApiService.post(
      '/messages/$conversationId/messages/$messageId/react',
      {'emoji': emoji},
    );
    final raw = data['data'] as Map<String, dynamic>? ?? {};
    return raw.map((k, v) =>
        MapEntry(k, (v as List).map((e) => e.toString()).toList()));
  }

  Future<void> setTyping(String conversationId, bool isTyping) async {
    try {
      await ApiService.post('/messages/$conversationId/typing', {'is_typing': isTyping});
    } catch (_) {}
  }

  Future<bool> getTyping(String conversationId) async {
    try {
      final data = await ApiService.get('/messages/$conversationId/typing');
      return data['data']?['is_typing'] == true;
    } catch (_) { return false; }
  }

  Future<void> markRead(String conversationId) async {
    try { await ApiService.post('/messages/$conversationId/read', {}); } catch (_) {}
  }

  Future<ConversationModel> getOrCreateConversation(String userId,
      {String? serviceId}) async {
    final body = serviceId != null ? {'service_id': serviceId} : <String, dynamic>{};
    final data = await ApiService.post('/messages/with/$userId', body);
    return ConversationModel.fromJson(data['data']);
  }
}