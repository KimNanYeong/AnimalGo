import 'package:flutter/material.dart';
import '../camera/CameraScreen.dart';
import '../home/FriendList.dart';
import '../home/HomeScreen.dart';
import '../../components/BottomBar.dart';
import '../../components/TopBar.dart';
import 'DeleteAccountScreen.dart';
import 'EditProfileScreen.dart';
import 'SettingsScreen.dart';
import '../chat/ChatListScreen.dart'; // ✅ 채팅 리스트 화면 추가
import '../village_test/Village.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPage createState() => _MyPage();
}
class _MyPage extends State<MyPage> with WidgetsBindingObserver {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('마이 페이지'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // 알림 버튼 동작 추가
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '닉네임', // 닉네임 부분 (크고 굵게)
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' 님 안녕하세요', // 나머지 부분 (작고 기본 스타일)
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경색 (흰색)
                foregroundColor: Colors.black, // 버튼 글씨 색상 (검은색)
                padding: EdgeInsets.symmetric(vertical: 16), // 버튼 내부 패딩
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // 텍스트 스타일
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                  side: BorderSide(color: Colors.black, width: 1.5), // 검은색 테두리
                ),
                minimumSize: Size(double.infinity, 50), // 버튼을 너비 최대로 설정
              ),
              child: Text('개인정보 수정'),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              child: Text('설정'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경색 (흰색)
                foregroundColor: Colors.black, // 버튼 글씨 색상 (검은색)
                padding: EdgeInsets.symmetric(vertical: 16), // 버튼 내부 패딩
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // 텍스트 스타일
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                  side: BorderSide(color: Colors.black, width: 1.5), // 검은색 테두리
                ),
                minimumSize: Size(double.infinity, 50), // 버튼을 너비 최대로 설정
              ),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteAccountScreen()),
                );
              },
              child: Text('회원탈퇴'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경색 (흰색)
                foregroundColor: Colors.black, // 버튼 글씨 색상 (검은색)
                padding: EdgeInsets.symmetric(vertical: 16), // 버튼 내부 패딩
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // 텍스트 스타일
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                  side: BorderSide(color: Colors.black, width: 1.5), // 검은색 테두리
                ),
                minimumSize: Size(double.infinity, 50), // 버튼을 너비 최대로 설정
              ),
            ),
            SizedBox(height: 25),
          ],
        ),
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
        currentIndex: 3,
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
                  pageBuilder: (context, animation, secondaryAnimation) => ChatListScreen(), // ✅ 채팅 리스트 화면으로 변경
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
















