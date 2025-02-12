import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChatRoomScreen extends StatefulWidget {
  final String friendName;
  final List<Map<String, String>> initialMessages;
  final Function(String, String) onMessageSent;

  const ChatRoomScreen({
    Key? key,
    required this.friendName,
    required this.initialMessages,
    required this.onMessageSent,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<Map<String, String>> messages;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);

    // ✅ 기존 메시지 유지
    messages = List<Map<String, String>>.from(widget.initialMessages);
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('a h:mm', 'ko_KR').format(dateTime);
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      String messageText = _messageController.text;
      String messageTime = _formatTime(DateTime.now());

      setState(() {
        messages.add({
          "text": messageText,
          "time": messageTime,
          "isSentByMe": "true",
        });
      });

      widget.onMessageSent(messageText, messageTime);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // ✅ 빈 공간 터치 시 키보드 내리기
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.friendName),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isSentByMe = messages[index]["isSentByMe"] == "true"; // ✅ String 비교

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment:
                      isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isSentByMe) // ✅ 받은 메시지일 경우 프로필 아이콘 추가
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[300],
                              child: Icon(Icons.person, color: Colors.black),
                            ),
                          ),
                        if (isSentByMe) // ✅ 보낸 메시지의 시간 (왼쪽)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              messages[index]["time"]!,
                              style: const TextStyle(color: Colors.black54, fontSize: 10),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSentByMe ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            messages[index]["text"]!,
                            style: TextStyle(color: isSentByMe ? Colors.white : Colors.black),
                          ),
                        ),
                        if (!isSentByMe) // ✅ 받은 메시지의 시간 (오른쪽)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              messages[index]["time"]!,
                              style: const TextStyle(color: Colors.black54, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "메시지 입력...",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
