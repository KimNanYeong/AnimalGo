import 'package:flutter/material.dart';
import 'FriendList.dart'; // FriendList 임포트
import '../../components/BottomBar.dart'; // BottomNavBar 컴포넌트 임포트
import '../../components/TopBar.dart'; // CustomAppBar 임포트

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> friends = [
    {"name": "복실이", "image": "assets/images/dog1.png"},
    {"name": "별이", "image": "assets/images/dog2.png"},
    {"name": "초코", "image": "assets/images/dog3.png"},
    {"name": "구름", "image": "assets/images/dog1.png"},
    {"name": "해피", "image": "assets/images/dog2.png"},
    {"name": "뽀삐", "image": "assets/images/dog3.png"},
    {"name": "토리", "image": "assets/images/dog1.png"},
    {"name": "루루", "image": "assets/images/dog2.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Topbar(
        title: "내 친구들 (${friends.length})",
        // showBackButton : true
      ), // CustomAppBar 사용
      body: FriendList(friends: friends), // FriendList 위젯 사용
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 카메라 버튼 동작 추가
        },
        backgroundColor: Colors.black,
        child: Icon(Icons.camera_alt, color: Colors.white),
      ),
      bottomNavigationBar: Bottombar(
        currentIndex: 0,
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
                      HomeScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      HomeScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      HomeScreen(),
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
