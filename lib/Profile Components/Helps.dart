import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  final List<ChatMessage> chatMessages = [
    ChatMessage(isUser: false, text: "Здравствуйте! Чем могу помочь?"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Помощь', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 10,
        backgroundColor: Colors.transparent,
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF121212), // Темный фон
                Color(0xFF37474F), // Чуть светлее темный
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFF121212), // Темный фон
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  final message = chatMessages[index];
                  return ChatBubble(message: message);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: TextField(
                onSubmitted: (text) {
                  final response = getResponse(text);
                  addMessage(response!);
                },
                decoration: InputDecoration(
                  hintText: 'Введите ваш вопрос...',
                  hintStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Color(0xFF37474F), // Темное поле ввода
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final response = getResponse();
                      addMessage(response!);
                    },
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? getResponse([String? userQuery]) {
    final responses = {
      "signup":
          "Чтобы зарегистрироваться, перейдите на страницу регистрации и заполните необходимые данные.",
      "login": "Для входа перейдите на страницу входа и введите свои данные.",
      "forgot password":
          "Если вы забыли пароль, вы можете сбросить его на странице восстановления пароля.",
      "default":
          "Извините, я не понимаю ваш вопрос. Пожалуйста, задайте другой вопрос или обратитесь в поддержку.",
    };

    final query = userQuery?.toLowerCase() ?? '';
    return responses.containsKey(query)
        ? responses[query]
        : responses["default"];
  }

  void addMessage(String text, {bool isUser = true}) {
    final message = ChatMessage(isUser: isUser, text: text);
    chatMessages.add(message);
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.green,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

class ChatMessage {
  final bool isUser;
  final String text;

  ChatMessage({required this.isUser, required this.text});
}
