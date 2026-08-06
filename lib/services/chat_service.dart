import 'dart:convert';
import 'package:va_bookats/models/chat_message_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'pusher_manager.dart';

typedef OnChatMessage = void Function(ChatMessageModel message);

/// Singleton GetxService that manages chat subscriptions
/// using the shared PusherManager
class ChatService extends GetxService {
  final PusherManager _pusherManager = Get.find<PusherManager>();

  int? _subscribedChatId;
  OnChatMessage? _onMessageCallback;
  Function(int chatId, int readerId)? _onReadCallback;
  Function(dynamic)? _currentEventHandler;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Subscribe to a private chat channel.
  /// Automatically unsubscribes from any previous channel first.
  Future<void> subscribeToChat(int chatId, OnChatMessage onMessage,
      {Function(int chatId, int readerId)? onRead}) async {
    if (_subscribedChatId == chatId) {
      _onMessageCallback = onMessage;
      _onReadCallback = onRead;
      return;
    }
    await unsubscribe();
    _subscribedChatId = chatId;
    _onMessageCallback = onMessage;
    _onReadCallback = onRead;

    try {
      _currentEventHandler = (dynamic event) {
        if (event is! PusherEvent) return;
        _onPusherEvent(event);
      };
      
      await _pusherManager.subscribe(
        channelName: 'private-conversation.$chatId',
        onEvent: _currentEventHandler!,
      );
      _log('Subscribed → private-conversation.$chatId');
    } catch (e) {
      _log('Subscribe error: $e');
    }
  }

  /// Unsubscribe from the active channel (called on chat screen close).
  Future<void> unsubscribe() async {
    if (_subscribedChatId != null) {
      try {
        if (_currentEventHandler != null) {
          await _pusherManager.unsubscribe(
            channelName: 'private-conversation.$_subscribedChatId',
            onEvent: _currentEventHandler,
          );
        }
        _log('Unsubscribed ← private-conversation.$_subscribedChatId');
      } catch (e) {
        _log('Unsubscribe error: $e');
      }
      _subscribedChatId = null;
      _onMessageCallback = null;
      _onReadCallback = null;
      _currentEventHandler = null;
    }
  }

  // ─── Pusher Event Handling ─────────────────────────────────────────────────

  void _onPusherEvent(PusherEvent event) {
    _log('Event [${event.eventName}] data: ${event.data}');

    if (event.eventName == 'new.message' ||
        event.eventName == 'App\\Events\\NewMessage') {
      _parseAndDispatch(event.data);
    } else if (event.eventName == 'conversation.message.read') {
      _handleReadEvent(event.data);
    }
  }

  void _parseAndDispatch(dynamic rawData) {
    _log('parseAndDispatch called, rawData type: ${rawData.runtimeType}');
    try {
      if (rawData == null) {
        _log('rawData is null');
        return;
      }
      Map<String, dynamic> data = rawData is String
          ? jsonDecode(rawData) as Map<String, dynamic>
          : rawData as Map<String, dynamic>;
      _log('parsed data: $data');
      
      // Check if data is wrapped in a "message" key (common in Laravel broadcasts)
      if (data.containsKey('message') && data['message'] is Map<String, dynamic>) {
        _log('found wrapped "message" key');
        data = data['message'] as Map<String, dynamic>;
      }
      
      final msg = ChatMessageModel.fromJson(data);
      _log('parsed ChatMessageModel: id=${msg.id}, senderId=${msg.senderId}');
      _onMessageCallback?.call(msg);
    } catch (e) {
      _log('Parse error: $e');
    }
  }

  void _handleReadEvent(dynamic rawData) {
    try {
      if (rawData == null) return;
      Map<String, dynamic> data = rawData is String
          ? jsonDecode(rawData) as Map<String, dynamic>
          : rawData as Map<String, dynamic>;
      final chatId = (data['conversation_id'] as num?)?.toInt();
      final readerId = (data['reader_id'] as num?)?.toInt();
      if (chatId != null && readerId != null) {
        _onReadCallback?.call(chatId, readerId);
      }
    } catch (e) {
      _log('Handle read event error: $e');
    }
  }

  // ─── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> onClose() async {
    await unsubscribe();
    super.onClose();
  }

  void _log(String msg) {
    if (kDebugMode) debugPrint('[ChatService] $msg');
  }
}
