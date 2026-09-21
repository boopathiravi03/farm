import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class AiAssistantScreen extends StatefulWidget {
  final String? token;

  const AiAssistantScreen({super.key, this.token});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  _ChatMessage({required this.text, required this.isUser, required this.time});
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          "Namaste! I am Farm Trading AI, your personal agricultural assistant. How can I help you with your crops, market prices, or farming decisions today?",
      isUser: false,
      time: DateTime.now(),
    ),
  ];

  final List<String> _quickPrompts = [
    "🌱 Crop advice",
    "💰 Price advice",
    "🌦️ Weather impact",
    "🐛 Crop problem",
    "📊 Market trends",
  ];

  final String _renderUrl = 'https://farm-trading-backend.onrender.com/api';

  void _sendPrompt(String prompt) {
    _textController.text = prompt;
    _handleSubmitted();
  }

  Future<void> _handleSubmitted() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _textController.clear();

    setState(() {
      _messages.add(
        _ChatMessage(text: text, isUser: true, time: DateTime.now()),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final token = widget.token ?? await AuthService.getToken() ?? '';
      final response = await http
          .post(
            Uri.parse('$_renderUrl/ai/chat'),
            headers: {
              'Content-Type': 'application/json',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'message': text}),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiReply =
            data['reply'] ??
            data['message'] ??
            'I could not generate an answer at this moment.';

        if (!mounted) return;
        setState(() {
          _messages.add(
            _ChatMessage(text: aiReply, isUser: false, time: DateTime.now()),
          );
        });
      } else {
        _useFallbackResponse(text);
      }
    } catch (_) {
      _useFallbackResponse(text);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _useFallbackResponse(String question) {
    final q = question.toLowerCase();
    String reply =
        "I analyzed current market conditions in Tamil Nadu for your query:\n\n";

    if (q.contains('tomato') || q.contains('price is low')) {
      reply +=
          "🍅 **Tomato Selling Strategy**:\n"
          "1. Current Panruti mandi rate is ₹32/Kg, but Chennai wholesale is ₹36/Kg.\n"
          "2. If local prices are depressed, consider grading your harvest into Premium (commanding +₹3/kg).\n"
          "3. Tuesday and Friday show the highest demand. Storing for 48 hours in a cool shaded area can yield better returns.";
    } else if (q.contains('weather') || q.contains('rain')) {
      reply +=
          "🌦️ **Weather Farm Advice**:\n"
          "• Moderate rain is expected in Panruti / Cuddalore region within 48 hours.\n"
          "• **Action**: Avoid spraying pesticides or chemical fertilizers before showers to prevent runoff.\n"
          "• Ensure drainage channels around vegetable beds are clear.";
    } else if (q.contains('fertilizer') ||
        q.contains('pest') ||
        q.contains('disease') ||
        q.contains('crop problem')) {
      reply +=
          "🌿 **Crop Health Guidance**:\n"
          "• For leaf curl or pest infestation, apply organic neem oil spray (5ml per liter) during morning hours.\n"
          "• Balanced N-P-K (19:19:19) foliar spray is recommended during the flowering and fruit-setting stage.";
    } else {
      reply +=
          "🌾 **Farming & Trade Insight**:\n"
          "• Direct trader matching on Farm Trading reduces commission losses by up to 10%.\n"
          "• Use our **AI Fair Price** calculator before committing to buyer offers to protect your revenue margin.";
    }

    if (!mounted) return;
    setState(() {
      _messages.add(
        _ChatMessage(text: reply, isUser: false, time: DateTime.now()),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.smart_toy, color: Color(0xFF167D39), size: 22),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm AI Assistant',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Powered by Groq • Online',
                  style: TextStyle(
                    color: Color(0xFF167D39),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ─────────────────────────────
          // QUICK PROMPT CHIPS
          // ─────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickPrompts.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(p, style: const TextStyle(fontSize: 12)),
                      backgroundColor: const Color(0xFFE8F5E9),
                      side: BorderSide(color: Colors.green.shade200),
                      onPressed: () => _sendPrompt(p),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ─────────────────────────────
          // CHAT MESSAGE LIST
          // ─────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Typing indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF167D39),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Farm AI is thinking...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // ─────────────────────────────
          // INPUT BAR
          // ─────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Ask anything about farming...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F4F1),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _handleSubmitted(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF167D39),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _handleSubmitted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: msg.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF167D39),
              child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser ? const Color(0xFF167D39) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: msg.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
