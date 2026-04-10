import 'package:flutter/material.dart';
import 'package:policysquare/data/models/chat_message.dart';
import 'package:policysquare/data/repositories/chat_repository.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hello! I'm your Policy Square assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ];

  List<ChatMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add User Message
    _messages.add(
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );
    notifyListeners();

    // 2. Simulate API Loading State
    _isLoading = true;
    notifyListeners();

    // 3. Get Response from Repository
    final responseMessage = await _repository.getBotResponse(text);

    _messages.add(responseMessage);

    _isLoading = false;
    notifyListeners();
  }
}
