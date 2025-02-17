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
  Timer? _timer;

  /// ✅ 자동 스크롤 함수 (마지막 메시지 위치로 이동)
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

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
            'http://122.46.89.124:7000/chat/chat/history/${widget
                .chatId}?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final String utf8String = utf8.decode(response.bodyBytes);
        final dynamic jsonData = json.decode(utf8String);

        //print("📥 서버 응답 데이터: $jsonData");

        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey("messages")) {
          List<dynamic> messagesList = jsonData["messages"];

          // 🔹 채팅방 ID에서 상대방 캐릭터 ID 추출 (예: user1_dog001 → dog001)
          List<String> chatParts = widget.chatId.split("_");
          String characId = chatParts.length > 1 ? chatParts.sublist(1).join(
              "_") : "";

          List<Map<String, dynamic>> newMessages = messagesList.map<
              Map<String, dynamic>>((message) {
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

          messages.sort((a, b) {
            DateTime timeA = DateFormat("a h:mm", "ko_KR").parse(a["time"]);
            DateTime timeB = DateFormat("a h:mm", "ko_KR").parse(b["time"]);
            return timeA.compareTo(timeB); // 시간순 정렬
          });

          if (mounted) { // ✅ 위젯이 활성화된 경우에만 setState 실행
            setState(() {
              messages.clear();
              messages.addAll(newMessages);
            });
            Future.delayed(
                Duration(milliseconds: 100), () => _scrollToBottom());
          }
        }
      }
    } catch (e) {
      if (mounted) {
        print("⚠️ JSON 파싱 오류: $e");
      }
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

    List<String> chatParts = widget.chatId.split("_");
    String characId = chatParts.length > 1
        ? chatParts.sublist(1).join("_")
        : "";

    // ✅ 1. Optimistic UI 적용 (사용자가 보낸 메시지를 즉시 화면에 추가)
    Map<String, dynamic> tempMessage = {
      "message": messageText,
      "isSentByMe": true,
      "time": formatTimestamp(messageTime),
      "isPending": true, // 서버 응답을 기다리는 상태
    };

    setState(() {
      messages.add(tempMessage);
      _scrollToBottom();
    });

    // ✅ 2. 입력창 초기화
    _messageController.clear();

    // ✅ 3. 서버에 메시지 전송
    Uri url = Uri.parse(
      'http://122.46.89.124:7000/chat/send_message'
          '?user_input=${Uri.encodeComponent(messageText)}'
          '&user_id=$userId'
          '&charac_id=$characId',
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("✅ 메시지 전송 성공");

        // ✅ 4. 서버 응답 후 `isPending` 제거 & 최신 메시지 동기화
        fetchChatHistory();
      } else {
        print('❌ 메시지 전송 실패: ${response.statusCode} | 응답: ${response.body}');
      }
    } catch (e) {
      print("⚠️ 네트워크 오류: $e");
    }
  }

  String friendNickname = ""; // 상대방 닉네임 저장 변수
  String friendProfileUrl = ""; // 상대방 프로필 사진 URL 저장 변수

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
                friendProfileUrl = chat["profile_url"] ?? ""; // 프로필 사진 URL 저장
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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    fetchChatHistory(); // 채팅 내역 불러오기
    // 10초마다 채팅 내역 갱신
    // ✅ 10초마다 채팅 내역 갱신 (타이머 설정)
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) { // ✅ 위젯이 살아있는지 확인 후 실행
        fetchChatHistory().then((_) {
          Future.delayed(Duration(milliseconds: 100), () {
            _scrollToBottom();
          });
        }); // ✅ 5초마다 자동 스크롤
      } else {
        timer.cancel(); // ✅ 위젯이 제거되었으면 타이머 해제
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ✅ 타이머 정리
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // ✅ 화면 터치하면 키보드 닫기
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // ✅ 키보드가 올라올 때 자동으로 스크롤 조정
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
              friendNickname.isNotEmpty ? friendNickname : widget.friendName),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Column(
          children: [
            // ✅ 채팅 메시지 리스트 (자동 스크롤)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isSentByMe = messages[index]["isSentByMe"] == true;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isSentByMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        // ✅ 상대방 메시지일 경우 프로필 사진 표시
                        if (!isSentByMe)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              radius: 20, // 프로필 사진 크기
                              backgroundImage: NetworkImage(
                                friendProfileUrl.isNotEmpty
                                    ? friendProfileUrl // 서버에서 가져온 프로필 사진 URL
                                    : 'https://via.placeholder.com/150', // 기본 이미지
                              ),
                            ),
                          ),

                        // ✅ 말풍선과 시간 표시
                        Flexible(
                          child: Column(
                            crossAxisAlignment:
                            isSentByMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSentByMe ? Colors.blueAccent : Colors
                                      .grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  messages[index]["message"]!,
                                  style: TextStyle(
                                    color: isSentByMe ? Colors.white : Colors
                                        .black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                messages[index]["time"]!,
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ✅ 입력창 - 키보드가 올라와도 가려지지 않도록 SafeArea 적용
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        onTap: () {
                          Future.delayed(Duration(milliseconds: 200), () {
                            _scrollToBottom(); // ✅ 입력창을 누르면 자동 스크롤
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "메시지를 입력하세요...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(vertical: 8,
                              horizontal: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blueAccent),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}