import 'package:flutter/material.dart';
import 'package:service_connect/data/fake_data.dart';
import 'package:service_connect/theme/app_theme.dart';

class ChatScreen extends StatelessWidget {
  final String quoteId;

  const ChatScreen({required this.quoteId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: AppTheme.lightGreyColor,
            child: const Center(
              child: Text(
                'Current Offer: \$45',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: FakeData.chatMessages.length,
              itemBuilder: (context, index) {
                final message = FakeData.chatMessages[index];
                if (message.isSystemMessage) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Offer Updated: '),
                            TextSpan(
                              text: '\$50',
                              style: TextStyle(decoration: TextDecoration.lineThrough),
                            ),
                            TextSpan(text: ' -> \$45'),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return Align(
                  alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                      color: message.isUser ? AppTheme.primaryColor : AppTheme.lightGreyColor,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(color: message.isUser ? Colors.white : Colors.black),
                    ),
                  ),
                );
              },
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Row(
                  children: [
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -60,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Accept & Pay \$45'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
