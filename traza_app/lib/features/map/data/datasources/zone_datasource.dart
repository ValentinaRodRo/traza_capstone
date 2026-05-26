import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/zone_model.dart';

abstract class ZoneDataSource {
  Future<List<ZoneModel>> getActiveZones();
  Stream<List<ZoneModel>> watchZones();
  void dispose();
}

class ZoneDataSourceImpl implements ZoneDataSource {
  final String baseUrl;
  final String wsBaseUrl;
  final http.Client httpClient;

  WebSocketChannel? _channel;
  StreamController<List<ZoneModel>>? _controller;
  Timer? _pingTimer;

  ZoneDataSourceImpl({
    required this.baseUrl,
    required this.wsBaseUrl,
    required this.httpClient,
  });

  // ──────────────────────────────────────────────
  //  REST — fetch inicial
  // ──────────────────────────────────────────────

  @override
  Future<List<ZoneModel>> getActiveZones() async {
    final uri = Uri.parse('$baseUrl/zones/active');
    debugPrint('[ZoneDS] GET $uri');
    try {
      final response = await httpClient
          .get(uri)
          .timeout(const Duration(seconds: 10));

      debugPrint('[ZoneDS] status: ${response.statusCode}');
      debugPrint('[ZoneDS] body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ZoneModel.listFromBroadcast(json);
      }
      throw Exception('Error al cargar zonas: ${response.statusCode}');
    } catch (e, st) {
      debugPrint('[ZoneDS] EXCEPTION: $e');
      debugPrint('[ZoneDS] STACKTRACE: $st');
      rethrow;
    }
  }

  // ──────────────────────────────────────────────
  //  WebSocket — stream de actualizaciones
  // ──────────────────────────────────────────────

  @override
  Stream<List<ZoneModel>> watchZones() {
    _controller?.close();
    _controller = StreamController<List<ZoneModel>>.broadcast();

    _connectWebSocket();

    return _controller!.stream;
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsBaseUrl/ws/zones'),
      );

      _channel!.stream.listen(
        (message) {
          if (message == 'pong') return;
          try {
            final json = jsonDecode(message as String) as Map<String, dynamic>;
            final zones = ZoneModel.listFromBroadcast(json);
            if (!(_controller?.isClosed ?? true)) {
              _controller!.add(zones);
            }
          } catch (_) {}
        },
        onError: (error) {
          debugPrint('[ZoneDS] WS error: $error');
          if (!(_controller?.isClosed ?? true)) {
            _controller!.addError(error);
          }
          _scheduleReconnect();
        },
        onDone: () => _scheduleReconnect(),
        cancelOnError: false,
      );

      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        try {
          _channel?.sink.add('ping');
        } catch (_) {}
      });
    } catch (e) {
      debugPrint('[ZoneDS] WS connect error: $e');
      if (!(_controller?.isClosed ?? true)) {
        _controller!.addError(e);
      }
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _pingTimer?.cancel();
    Future.delayed(const Duration(seconds: 5), () {
      if (!(_controller?.isClosed ?? true)) {
        _connectWebSocket();
      }
    });
  }

  // ──────────────────────────────────────────────
  //  Cleanup
  // ──────────────────────────────────────────────

  @override
  void dispose() {
    _pingTimer?.cancel();
    _channel?.sink.close();
    _controller?.close();
  }
}