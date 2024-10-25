import 'package:flutter/material.dart';
import 'package:intelligrade/controller/chatgpt_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For saving/loading chat history
import 'custom_navigation_bar.dart'; // Import the custom navigation bar
import 'dart:convert'; // For encoding and decoding chat history

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String _role = 'student'; // Role toggle for student/teacher
  final ScrollController _scrollController =
      ScrollController(); // For scrolling the chat
  SharedPreferences? _prefs; // SharedPreferences for saving chat history

  @override
  void initState() {
    super.initState();
    _loadChatHistory(); // Load chat history when screen is initialized
  }

  // Load chat history from SharedPreferences
  Future<void> _loadChatHistory() async {
    _prefs = await SharedPreferences.getInstance();
    String? savedMessages = _prefs?.getString('chat_history');
    if (savedMessages != null) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(jsonDecode(savedMessages));
      });
    }
  }

  // Save chat history to SharedPreferences
  Future<void> _saveChatHistory() async {
    if (_prefs != null) {
      await _prefs?.setString('chat_history', jsonEncode(_messages));
    }
  }

  // Function to handle user message sending and API response
  Future<void> _sendMessage() async {
    final input = _controller.text;

    if (input.isEmpty) {
      return;
    }

    // Update UI to show user's message and reset text field
    setState(() {
      _messages.add({'text': input, 'sender': 'user'});
      _isLoading = true; // Show a loading indicator while waiting for response
    });

    _controller.clear(); // Clear the input field
    _scrollToBottom(); // Scroll to the bottom after sending the message
    await _saveChatHistory(); // Save chat history

    try {
      // Get ChatGPT response
      final chatGPTService = ChatGPTService();
      final prompt =
          _role == 'teacher' ? "You are assisting a teacher. $input" : input;
      final response = await chatGPTService.getChatResponse(prompt);

      setState(() {
        _messages.add({'text': response, 'sender': 'bot'});
        _isLoading = false;
      });

      _scrollToBottom(); // Scroll to the bottom after receiving the bot response
      await _saveChatHistory(); // Save chat history after bot response
    } catch (error) {
      setState(() {
        _messages.add({
          'text': 'Error: Could not fetch response. Please try again.',
          'sender': 'bot'
        });
        _isLoading = false;
      });
    }
  }

  // Function to clear chat history
  void _clearChat() {
    setState(() {
      _messages.clear();
    });
    _saveChatHistory(); // Save the empty state to clear saved chat history
  }

  // Function to toggle role (student/teacher)
  void _toggleRole() {
    setState(() {
      _role = _role == 'student' ? 'teacher' : 'student';
    });
  }

  // Scroll to the bottom of the chat list
  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ask Chatbot!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearChat, // Clear chat history
          ),
          IconButton(
            icon: Icon(Icons.switch_account),
            onPressed: _toggleRole, // Toggle role between teacher and student
            tooltip:
                'Switch role to ${_role == 'student' ? 'Teacher' : 'Student'}',
          ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Row(
        children: [
          // Left navigation bar (persistent)
          Container(
            width: 250, // Width of the left navigation bar
            color: Colors.grey[200],
            child: CustomNavigationBar(
              selectedIndex:
                  6, // Set the selected index to 'Chatbot Assistance'
            ),
          ),
          // Main chat content
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller:
                        _scrollController, // Attach the ScrollController
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUserMessage = message['sender'] == 'user';

                      return Align(
                        alignment: isUserMessage
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUserMessage
                                ? Colors.blueAccent
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              color:
                                  isUserMessage ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(), // Loading indicator
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Enter your message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
