import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';

class WebSocketService {
  static const String serverOrigin = String.fromEnvironment(
    'SERVER_ORIGIN',
    defaultValue: 'https://rset-student-api.onrender.com',
  );

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  String? _authToken;
  bool _manuallyDisconnected = false;
  final Set<String> _subscriptions = {};
  Function(Map<String, dynamic>)? onMessageReceived;
  Function()? onConnected;
  Function()? onDisconnected;

  bool get isConnected => _channel != null;

  Future<void> connect(String authToken) async {
    if (authToken == 'rset-parent-offline-session') return;
    _authToken = authToken;
    _manuallyDisconnected = false;
    _reconnectTimer?.cancel();
    try {
      final origin = Uri.parse(serverOrigin);
      final uri = origin.replace(
        scheme: origin.scheme == 'https' ? 'wss' : 'ws',
        path: '/ws',
        queryParameters: {'token': authToken},
      );
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;
      onConnected?.call();
      for (final channel in _subscriptions) {
        _sendSubscription(channel);
      }

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            onMessageReceived?.call(data);
          } catch (e) {
            debugPrint('Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          _handleDisconnect();
        },
      );
    } catch (e) {
      debugPrint('Failed to connect to WebSocket: $e');
      _handleDisconnect();
    }
  }

  void subscribe(String channel) {
    _subscriptions.add(channel);
    if (_channel != null) _sendSubscription(channel);
  }

  void _sendSubscription(String channel) {
    _channel?.sink.add(jsonEncode({
      'action': 'subscribe',
      'channel': channel,
    }));
  }

  void _handleDisconnect() {
    _channel = null;
    onDisconnected?.call();
    if (!_manuallyDisconnected && _authToken != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(
        const Duration(seconds: 3),
        () => connect(_authToken!),
      );
    }
  }

  void disconnect() {
    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    onDisconnected?.call();
  }
}
