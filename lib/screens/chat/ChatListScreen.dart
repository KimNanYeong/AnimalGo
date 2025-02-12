import 'package:flutter/material.dart';
import 'ChatRoomScreen.dart'; // ✅ 채팅방 화면 추가
import '../camera/CameraScreen.dart'; // ✅ 카메라 화면 추가
import '../../components/BottomBar.dart'; // ✅ 하단 네비게이션 바 추가
import '../myPage/my_page.dart';
import '../home/HomeScreen.dart'; // ✅ 홈 화면 추가

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> chatRooms = [
    {
      "name": "복실이",
      "lastMessage": "안녕! 😊",
      "time": "오전 10:30",
      "messages": [
        {"text": "안녕! 😊", "time": "오전 10:30", "isSentByMe": "false"},
      ],
    },
    {
      "name": "별이",
      "lastMessage": "오늘 산책 가고 싶어!",
      "time": "오전 9:15",
      "messages": [
        {"text": "오늘 산책 가고 싶어!", "time": "오전 9:15", "isSentByMe": "false"},
      ],
    },
  ];

  void _updateLastMessage(String friendName, String newMessage, String newTime) {
    setState(() {
      for (var chat in chatRooms) {
        if (chat["name"] == friendName) {
          chat["lastMessage"] = newMessage;
          chat["time"] = newTime;

          if (chat["messages"] == null || chat["messages"] is! List<Map<String, String>>) {
            chat["messages"] = <Map<String, String>>[];
          }

          (chat["messages"] as List<Map<String, String>>).add({
            "text": newMessage,
            "time": newTime,
            "isSentByMe": "true",
          });
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("채팅 목록", style: TextStyle(fontWeight: FontWeight.bold)), // ✅ 글씨 강조
        backgroundColor: Colors.white, // ✅ 완전 흰색 배경
        foregroundColor: Colors.black, // ✅ 글씨 및 아이콘 검은색 유지
        elevation: 0, // ✅ 그림자 제거 (회색 배경 문제 해결)
        shadowColor: Colors.transparent, // ✅ 혹시 남아있는 그림자 제거
        actions: [

          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // TODO: 설정 화면 이동
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.black),
            ),
            title: Text(chatRooms[index]["name"]!),
            subtitle: Text(chatRooms[index]["lastMessage"]!), // ✅ 마지막 메시지 표시
            trailing: Text(chatRooms[index]["time"]!, style: TextStyle(color: Colors.grey)),
            onTap: () {
              List<Map<String, String>> formattedMessages =
                  (chatRooms[index]["messages"] as List<dynamic>?)?.map((msg) {
                    return {
                      "text": msg["text"].toString(),
                      "time": msg["time"].toString(),
                      "isSentByMe": msg["isSentByMe"].toString(),
                    };
                  }).toList() ?? [];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomScreen(
                    friendName: chatRooms[index]["name"]!,
                    initialMessages: formattedMessages,
                    onMessageSent: (newMessage, newTime) {
                      _updateLastMessage(chatRooms[index]["name"]!, newMessage, newTime);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CameraScreen()),
          );
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.camera_alt, color: Colors.white),
      ),
      bottomNavigationBar: Bottombar(
        currentIndex: 2, // ✅ 현재 페이지가 채팅 리스트 화면이므로 2로 설정
        onTabSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => ChatListScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => MyPage(),
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
