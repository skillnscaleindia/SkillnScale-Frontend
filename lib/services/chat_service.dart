import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(ref);
});

class ChatService {
  final Ref _ref;

  ChatService(this._ref);

  /// Get all chat rooms for the current user
  Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/chat/rooms');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to load chat rooms: $e');
    }
  }

  /// Create a chat room with a professional for a service request
  Future<Map<String, dynamic>> createChatRoom({
    required String requestId,
    required String professionalId,
  }) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.post('/chat/rooms', data: {
        'request_id': requestId,
        'professional_id': professionalId,
      });
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }

  /// Get messages in a chat room
  Future<List<Map<String, dynamic>>> getMessages(String roomId) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.get('/chat/rooms/$roomId/messages');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  /// Send a text message
  Future<Map<String, dynamic>> sendMessage({
    required String roomId,
    required String content,
    String messageType = 'text',
    String? mediaUrl,
    double? duration,
  }) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.post(
        '/chat/rooms/$roomId/messages',
        data: {
          'content': content,
          'message_type': messageType,
          'media_url': mediaUrl,
          'duration': duration,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Send a price proposal
  Future<Map<String, dynamic>> proposePrice({
    required String roomId,
    required double price,
  }) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.post(
        '/chat/rooms/$roomId/messages',
        data: {
          'content': 'Price proposal: ₹${price.toStringAsFixed(0)}',
          'message_type': 'price_proposal',
          'proposed_price': price,
        },
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to propose price: $e');
    }
  }

  /// Accept the latest price proposal → creates a booking
  Future<Map<String, dynamic>> acceptPrice(String roomId) async {
    try {
      final apiClient = _ref.read(apiClientProvider);
      final response = await apiClient.client.post('/chat/rooms/$roomId/accept-price');
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to accept price: $e');
    }
  }
}
