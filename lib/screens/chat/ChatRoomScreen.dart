import 'dart:convert';
import 'dart:async'; // Timer 사용
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId; // 서버에서 관리하는 채팅방 ID
  final String friendName;

  const ChatRoomScreen({
    Key? key,
    required this.chatId,
    required this.friendName,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final String userId = '1'; // userId 고정
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = []; // 채팅 내역 리스트

  /// 날짜/시간 포맷 변환 함수 (12시간/24시간 모두 지원)
  String formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) {
      print("⚠️ formatTimestamp: timestamp가 null이거나 비어 있음");
      return "unknown";
    }
    try {
      // print("🔍 formatTimestamp: 원본 timestamp → $timestamp");

      // "UTC+0900" 제거 (있을 경우)
      timestamp = timestamp.replaceAll(RegExp(r' UTC[+-]\d{4}'), '').trim();

      // 한국어 날짜 형식을 일부 ISO 형식처럼 변경
      timestamp = timestamp
          .replaceAll("년 ", "-")
          .replaceAll("월 ", "-")
          .replaceAll("일", "")
          .replaceAll("시 ", ":")
          .replaceAll("분 ", ":")
          .replaceAll("초", "")
          .replaceAll("오전 ", "AM ")
          .replaceAll("오후 ", "PM ")
          .trim();

      // print("🔹 변환된 서버 timestamp → $timestamp");

      DateTime parsedDate;
      if (timestamp.contains("AM") || timestamp.contains("PM")) {
        // AM/PM이 포함된 경우 재배치 (예: "2025-02-14 PM 02:40:07" → "2025-02-14 02:40:07 PM")
        RegExp amPmRegex = RegExp(r'^(\d{4}-\d{2}-\d{2}) (AM|PM) (.+)$');
        if (amPmRegex.hasMatch(timestamp)) {
          timestamp = timestamp.replaceAllMapped(amPmRegex, (match) {
            return "${match.group(1)} ${match.group(3)} ${match.group(2)}";
          });
        }
        parsedDate = DateFormat("yyyy-MM-dd hh:mm:ss a").parse(timestamp);
      } else {
        // 24시간 형식인 경우
        parsedDate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timestamp);
      }

      // 최종적으로 한국어 12시간 형식으로 변환 (예: "오후 2:40")
      String formattedTime = DateFormat("a h:mm", "ko_KR").format(parsedDate);
      // print("✅ formatTimestamp 최종 변환 → $formattedTime");
      return formattedTime;
    } catch (e) {
      // print("⚠️ formatTimestamp 오류: $e | 원본: $timestamp");
      return "unknown";
    }
  }

  /// 서버에서 채팅 내역 가져오기
  Future<void> fetchChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://122.46.89.124:7000/chat/chat/history/${widget.chatId}?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final String utf8String = utf8.decode(response.bodyBytes);
        final dynamic jsonData = json.decode(utf8String);

        print("📥 서버 응답 데이터: $jsonData");

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey("messages")) {
          List<dynamic> messagesList = jsonData["messages"];

          // 🔹 채팅방 ID에서 상대방 캐릭터 ID 추출 (예: user1_dog001 → dog001)
          List<String> chatParts = widget.chatId.split("_");
          String characId = chatParts.length > 1 ? chatParts.sublist(1).join("_") : "";

          List<Map<String, dynamic>> newMessages = messagesList.map<Map<String, dynamic>>((message) {
            String rawTimestamp = message["timestamp"]?.toString() ?? "unknown";
            String formattedTime = formatTimestamp(rawTimestamp);

            // 🔹 sender 값이 userId와 같다면 내 메시지
            bool isSentByMe = message["sender"].toString() == userId;

            return {
              "message": message["content"]?.toString() ?? "",
              "isSentByMe": isSentByMe,
              "time": formattedTime,
            };
          }).toList();

          setState(() {
            messages.clear();
            messages.addAll(newMessages);
          });

          print("✅ 최신 메시지 반영 완료: $messages");
        }
      } else {
        print('❌ 채팅 내역 불러오기 실패: ${response.statusCode}');
      }
    } catch (e) {
      print("⚠️ JSON 파싱 오류: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchChatHistory();
  }

  /// 메시지 전송 함수 (Optimistic Update 적용)
  Future<void> sendMessage() async {
    if (_messageController.text.isEmpty) return;

    String messageText = _messageController.text;
    DateTime now = DateTime.now();
    String messageTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);

    // 🔹 채팅방 ID에서 상대방 캐릭터 ID 추출 (예: user1_dog001 → dog001)
    List<String> chatParts = widget.chatId.split("_");
    String characId = chatParts.length > 1 ? chatParts.sublist(1).join("_") : "";

    Map<String, dynamic> tempMessage = {
      "message": messageText,
      "isSentByMe": true,
      "time": formatTimestamp(messageTime),
      "isPending": true,
    };

    setState(() {
      messages.add(tempMessage);
    });

    _messageController.clear();

    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    Uri url = Uri.parse(
      'http://122.46.89.124:7000/chat/send_message'
          '?user_input=${Uri.encodeComponent(messageText)}'
          '&user_id=$userId'
          '&charac_id=$characId', // ✅ 올바른 캐릭터 ID 사용
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("✅ 메시지 전송 성공");
        Future.delayed(Duration(seconds: 1), () => fetchChatHistory());
        Future.delayed(Duration(seconds: 3), () => fetchChatHistory());
      } else {
        print('❌ 메시지 전송 실패: ${response.statusCode} | 응답: ${response.body}');
      }
    } catch (e) {
      print("⚠️ 네트워크 오류: $e");
    }
  }

  String friendNickname = ""; // 상대방 닉네임 저장 변수

  Future<void> fetchChatRoomInfo() async {
    try {
      final response = await http.get(
        Uri.parse('http://122.46.89.124:7000/chat/chat_rooms?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final String utf8String = utf8.decode(response.bodyBytes);
        final dynamic jsonData = json.decode(utf8String);

        if (jsonData is Map<String, dynamic> && jsonData.containsKey("chats")) {
          for (var chat in jsonData["chats"]) {
            if (chat["chat_id"] == widget.chatId) {
              setState(() {
                friendNickname = chat["nickname"]; // 상대방 캐릭터 닉네임 저장
              });
              break;
            }
          }
        }
      }
    } catch (e) {
      print("⚠️ 채팅방 정보 가져오기 오류: $e");
    }
  }

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    fetchChatHistory(); // 채팅 내역 불러오기
    // 10초마다 채팅 내역 갱신
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchChatHistory();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 내리기
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(friendNickname.isNotEmpty ? friendNickname : widget.friendName),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Column(
          children: [
            // 채팅 메시지 리스트
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isSentByMe = messages[index]["isSentByMe"] == true;

                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isSentByMe)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                messages[index]["time"]!,
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 10),
                              ),
                            ),
                          if (!isSentByMe)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.person, color: Colors.black),
                              ),
                            ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSentByMe
                                    ? Colors.blueAccent
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                  bottomLeft: isSentByMe
                                      ? Radius.circular(8)
                                      : Radius.zero,
                                  bottomRight: isSentByMe
                                      ? Radius.zero
                                      : Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                messages[index]["message"]!,
                                style: TextStyle(
                                    color: isSentByMe
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                          if (!isSentByMe)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                messages[index]["time"]!,
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 메시지 입력창
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "메시지를 입력하세요...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) => sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: sendMessage,
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