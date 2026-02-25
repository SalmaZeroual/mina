import '../models/message_model.dart';

abstract class MessageSocketDataSource {
  Stream<MessageModel> watchMessages({required String conversationId});
  void connect({required String token});
  void disconnect();
}

class MessageSocketDataSourceImpl implements MessageSocketDataSource {
  // Replace with your WebSocket client (e.g. socket_io_client)
  dynamic _socket;

  @override
  void connect({required String token}) {
    // TODO: Initialize socket connection
    // _socket = io(ApiEndpoints.socketUrl, OptionBuilder()
    //   .setTransports(['websocket'])
    //   .setExtraHeaders({'Authorization': 'Bearer $token'})
    //   .build());
  }

  @override
  Stream<MessageModel> watchMessages({required String conversationId}) {
    // TODO: Return stream from socket events
    // return Stream.fromIterable([]).asBroadcastStream();
    throw UnimplementedError('Implement with your socket client');
  }

  @override
  void disconnect() {
    _socket?.disconnect();
  }
}