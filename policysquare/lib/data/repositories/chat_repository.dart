import 'package:policysquare/data/models/chat_message.dart';

class ChatRepository {
  Future<ChatMessage> getBotResponse(String message) async {
    // Simulate Network Delay (1 second)
    await Future.delayed(const Duration(seconds: 1));

    return _generateMockResponse(message);
  }

  ChatMessage _generateMockResponse(String input) {
    final lower = input.toLowerCase();
    String responseText;

    if (lower.contains('quote') ||
        lower.contains('price') ||
        lower.contains('cost')) {
      responseText =
          "I can help you get a quote! Please visit the Home screen and select an insurance category (Motor, Health, etc.) to get started.";
    } else if (lower.contains('motor') ||
        lower.contains('car') ||
        lower.contains('vehicle')) {
      responseText =
          "For Motor Insurance, we offer Comprehensive and Third-Party Liability plans. Do you have a specific vehicle in mind?";
    } else if (lower.contains('health') || lower.contains('medical')) {
      responseText =
          "Our Health Insurance plans cover hospitalization, critical illness, and routine checkups. Plans start from \$15/month.";
    } else if (lower.contains('claim')) {
      responseText =
          "To file a claim, please go to your Profile > Claim History section, or contact our support hotline at 1-800-POLICY.";
    } else if (lower.contains('hi') ||
        lower.contains('hello') ||
        lower.contains('hey')) {
      responseText = "Hi there! Looking for insurance advice or support?";
    } else {
      responseText =
          "I'm a virtual assistant. I can help with general queries about our policies. For specific account details, please check your Profile.";
    }

    return ChatMessage(
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
}
