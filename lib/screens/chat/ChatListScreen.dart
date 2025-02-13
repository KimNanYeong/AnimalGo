import 'package:flutter/material.dart';
import 'ChatRoomScreen.dart';
import '../camera/CameraScreen.dart';
import '../../components/BottomBar.dart';
import '../myPage/my_page.dart';
import '../home/HomeScreen.dart';
import '../village_test/Village.dart';

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
                setState(() {
                  chatRooms.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${chatRooms[index]["name"]} 채팅방을 나갔습니다.")),
                );
              },
              child: Text("나가기", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
        shadowColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: chatRooms.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(chatRooms[index]["name"]),
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
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.exit_to_app, color: Colors.white),
                ],
              ),
            ),
            confirmDismiss: (direction) async {
              _leaveChat(index);
              return false; // ✅ 다이얼로그에서 직접 삭제 처리하기 때문에 여기선 false 반환
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.black),
              ),
              title: Text(chatRooms[index]["name"]!),
              subtitle: Text(chatRooms[index]["lastMessage"]!),
              trailing: Text(chatRooms[index]["time"]!, style: TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatRoomScreen(
                      friendName: chatRooms[index]["name"]!,
                      initialMessages: chatRooms[index]["messages"] as List<Map<String, String>>,
                      onMessageSent: (newMessage, newTime) {
                        setState(() {
                          chatRooms[index]["lastMessage"] = newMessage;
                          chatRooms[index]["time"] = newTime;
                          (chatRooms[index]["messages"] as List<Map<String, String>>).add({
                            "text": newMessage,
                            "time": newTime,
                            "isSentByMe": "true",
                          });
                        });
                      },
                    ),
                  ),
                );
              },
            ),
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
        currentIndex: 2,
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
                  pageBuilder: (context, animation, secondaryAnimation) => VillageScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 2: // ✅ 채팅 리스트 화면으로 이동하도록 수정
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ChatListScreen(), // ✅ 채팅 리스트 화면으로 변경
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
