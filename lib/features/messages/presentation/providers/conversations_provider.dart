import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/message_remote_datasource.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../domain/repositories/message_repository.dart';
import 'messages_state.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(
    MessageRemoteDataSource(ref.read(apiClientProvider)),
  );
});

final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  return ConversationsNotifier(ref.read(messageRepositoryProvider));
});

class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final MessageRepository _repo;
  ConversationsNotifier(this._repo) : super(const ConversationsInitial());

  // appelé par MessagesScreen initState + onRefresh
  Future<void> load() async {
    state = const ConversationsLoading();
    final result = await _repo.getConversations();
    result.fold(
      (f) => state = ConversationsError(f.message),
      (convs) => state = ConversationsLoaded(conversations: convs),
    );
  }

  // appelé quand on veut contacter quelqu'un
  Future<String?> startConversation(String userId) async {
    final result = await _repo.startConversation(userId: userId);
    return result.fold(
      (f) { state = ConversationsError(f.message); return null; },
      (conv) { load(); return conv.id; },
    );
  }
}