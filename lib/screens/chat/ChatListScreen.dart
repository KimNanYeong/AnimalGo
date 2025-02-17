import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../components/BottomBar.dart';
import '../home/HomeScreen.dart';
import '../village/VillageScreen.dart';
import 'ChatRoomScreen.dart';
import '../myPage/my_page.dart';
import 'package:intl/intl.dart'; // ✅ 날짜 변환을 위해 추가
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final String serverUrl = 'http://122.46.89.124:7000';
  final String userId = '1';
  List<Map<String, dynamic>> chatRooms = [];

  @override
  void initState() {
    super.initState();
    fetchChatList();
  }

  /// 다양한 날짜 형식을 지원하는 변환 함수
  String formatDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return "unknown";
    }
    try {
      DateTime dateTime;
      // 우선 ISO 8601 형식 파싱 시도
      try {
        dateTime = DateTime.parse(dateTimeString);
      } catch (_) {
        // ISO 형식이 아니면, 수동 변환 진행
        String converted = dateTimeString
            .replaceAll("년 ", "-")
            .replaceAll("월 ", "-")
            .replaceAll("일", "")
            .replaceAll("시 ", ":")
            .replaceAll("분 ", ":")
            .replaceAll("초", "")
            .replaceAll("UTC+0900", "")
            .trim();

        if (converted.contains("AM") || converted.contains("PM")) {
          RegExp amPmRegex = RegExp(r'^(\d{4}-\d{2}-\d{2}) (AM|PM) (.+)$');
          if (amPmRegex.hasMatch(converted)) {
            converted = converted.replaceAllMapped(amPmRegex, (match) {
              return "${match.group(1)} ${match.group(3)} ${match.group(2)}";
            });
            dateTime = DateFormat("yyyy-MM-dd hh:mm:ss a").parse(converted);
          } else {
            dateTime = DateFormat("yyyy-MM-dd hh:mm:ss a").parse(converted);
          }
        } else {
          // 24시간 형식
          dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(converted);
        }
      }
      return DateFormat('MM/dd').format(dateTime);
    } catch (e) {
      print("⚠️ 날짜 변환 오류: $e");
      return "unknown";
    }
  }

  /// 서버에서 채팅 목록을 가져오는 함수
  Future<void> fetchChatList() async {
    print("🔄 [ChatListScreen] 채팅 목록을 불러오는 중...");
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/chat/chat/list/1'),
        headers: {"Accept-Charset": "utf-8"},
      );

      print("🔍 서버 원본 응답: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final String utf8String = utf8.decode(response.bodyBytes);
          final Map<String, dynamic> responseData = json.decode(utf8String);
          //print("🔍 JSON 변환 성공: $responseData");

          final List<dynamic>? chatList = responseData["chats"];

          if (chatList == null || chatList.isEmpty) {
            print("⚠️ 서버에서 받은 채팅 목록이 비어 있음!");
            setState(() {
              chatRooms = [];
            });
            return;
          }

          setState(() {
            chatRooms = chatList
                .where((chat) => chat["chat_id"] != null)
                .map((chat) {
              final lastMessage = chat["last_message"] ?? {};
              return {
                "chat_id": chat["chat_id"]?.toString() ?? "unknown_id",
                "nickname": chat["nickname"]?.toString() ?? "알 수 없는 사용자",
                "personality": chat["personality"]?.toString() ?? "unknown",
                "create_at": formatDate(chat["create_at"]),
                "last_active_at": formatDate(chat["last_active_at"]),
                "last_message": {
                  "content": lastMessage["content"]?.toString() ??
                      "메시지가 없습니다.",
                  "sender": lastMessage["sender"]?.toString() ?? "unknown",
                  "timestamp": formatDate(lastMessage["timestamp"])
                }
              };
            }).toList();

            //print("✅ 변환된 chatRooms 데이터: $chatRooms");
          });
        } catch (jsonError) {
          print("⚠️ JSON 변환 오류: $jsonError");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("서버 응답을 처리할 수 없습니다.")),
          );
        }
      } else {
        print('❌ 서버 응답 오류: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버 오류: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print('⚠️ 네트워크 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("서버에 연결할 수 없습니다. 네트워크를 확인하세요.")),
      );
    }
  }

  /// 채팅방 나가기 (삭제) 요청
  Future<void> deleteChat(String chatId, int index) async {
    final response = await http.delete(
      Uri.parse('http://yourserver.com/chat/chat/$chatId/delete'),
    );

    if (response.statusCode == 200) {
      setState(() {
        chatRooms.removeAt(index);
      });
    } else {
      print('채팅방 삭제 실패: ${response.statusCode}');
    }
  }

  void _leaveChat(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("채팅방 나가기"),
          content: Text("${chatRooms[index]["name"]} 채팅방을 나가시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                deleteChat(chatRooms[index]["id"], index);
                Navigator.pop(context);
              },
              child: Text("나가기", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchChatList(); // ✅ 화면이 다시 나타날 때 채팅 목록 갱신
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("채팅 목록", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: chatRooms.isEmpty
          ? Center(
        child: Text(
          "채팅방이 없습니다.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(chatRooms[index]["chat_id"] ?? "unknown_id"),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "나가기",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.exit_to_app, color: Colors.white),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              _leaveChat(index);
              return false;
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.black),
              ),
              title: Text(
                  chatRooms[index]["nickname"] ?? "알 수 없는 사용자"),
              subtitle: Text(chatRooms[index]["last_message"]["content"] ??
                  "메시지가 없습니다."),
              trailing: Text(
                chatRooms[index]["last_active_at"] ?? "unknown",
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(
                      chatId: chatRooms[index]["chat_id"] ?? "unknown_id",
                      friendName: chatRooms[index]["nickname"] ?? "알 수 없는 사용자",
                    ),
                  ),
                );
                fetchChatList(); // ✅ 채팅방에서 나올 때 최신 메시지 다시 불러오기
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Bottombar(
        currentIndex: 2,
        onTabSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      HomeScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      VillageScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ChatListScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MyPage(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
          }
        },
      ),
    );
  }
}