import 'package:attendence_system/features/app_background.dart';
import 'package:flutter/material.dart';

import '../../../../main.dart';

class AskAIScreen extends StatefulWidget {
  const AskAIScreen({super.key});

  @override
  State<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends State<AskAIScreen> {

  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();


  Future<String> _getAIResponse(String query) async {
    await Future.delayed(const Duration(seconds: 1));
    return "This is the AI response to your question: '$query'";
  }


  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': isUser,
      });
    });
  }
  
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    
    _addMessage(_controller.text, true);

    final query = _controller.text;
    _controller.clear();
    
    final aiResponse = await _getAIResponse(query);
    _addMessage(aiResponse, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ask AI", style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: AppBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return _buildMessageBubble(message['text'], message['isUser']);
                },
              ),
            ),
        
            // Input Field
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  // Build a single message bubble
  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? primaryColor : veryLightGray,
          borderRadius: BorderRadius.circular(15),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Build the input field with send button
  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type your question...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: veryLightGray,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: _sendMessage,
            icon: Icon(Icons.send, color: primaryColor),
          ),
        ],
      ),
    );
  }
}