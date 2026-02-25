import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/message_repository.dart';
import 'conversations_provider.dart';
import 'messages_state.dart';

final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, conversationId) => ChatNotifier(
    ref.read(messageRepositoryProvider),
    conversationId,
  ),
);

class ChatNotifier extends StateNotifier<ChatState> {
  final MessageRepository _repo;
  final String conversationId;

  ChatNotifier(this._repo, this.conversationId) : super(const ChatInitial());

  // appelé par ChatScreen initState
  Future<void> init() async {
    state = const ChatLoading();
    final result = await _repo.getMessages(conversationId: conversationId);
    result.fold(
      (f) => state = ChatError(f.message),
      (msgs) => state = ChatLoaded(messages: msgs),
    );
  }

  // appelé par ChatScreen : notifier.send(text)
  Future<void> send(String content) async {
    final result = await _repo.sendMessage(
      conversationId: conversationId,
      content: content,
    );
    result.fold(
      (f) => state = ChatError(f.message),
      (msg) {
        if (state is ChatLoaded) {
          final msgs = [...(state as ChatLoaded).messages, msg];
          state = (state as ChatLoaded).copyWith(messages: msgs);
        }
      },
    );
  }

  // appelé par ChatScreen onChanged
  void startTyping() {}
  void stopTyping()  {}

  // appelé par socket : user_typing event
  void setTyping({required String name}) {
    if (state is ChatLoaded) {
      state = (state as ChatLoaded).copyWith(
        someoneTyping: true,
        typingName: name,
      );
    }
  }

  // appelé par socket : user_stopped_typing event
  void clearTyping() {
    if (state is ChatLoaded) {
      state = (state as ChatLoaded).copyWith(
        someoneTyping: false,
        typingName: '',
      );
    }
  }
}