import 'package:flutter/material.dart';
import 'package:animalgo/screens/home/HomeScreen.dart';
import 'package:animalgo/screens/myPage/my_page.dart';
import 'package:animalgo/components/BottomBar.dart';

class CharacterScreen extends StatefulWidget{
  const CharacterScreen({Key? key}) : super(key: key);

  @override
  _CharacterscreenState createState() => _CharacterscreenState();
}

class _CharacterscreenState extends State<CharacterScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text("상세보기"),
        actions: [
          IconButton(
            icon: const CircleAvatar(
              backgroundImage: AssetImage("assets/images/dog1.png"), // 프로필 이미지
            ),
            onPressed: () {
              // 프로필 버튼 액션
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 프로필 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/images/dog2.png"), // 강아지 이미지
                  
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          "닉네임",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.male, color: Colors.blue),
                      ],
                    ),
                    const Text(
                      "25.01.31",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 친밀도 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("❤️ 친밀도 : ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Icon(Icons.favorite, color: Colors.black),
                Icon(Icons.favorite, color: Colors.black),
                Icon(Icons.favorite, color: Colors.black),
                Icon(Icons.favorite_border, color: Colors.black),
                Icon(Icons.favorite_border, color: Colors.black),
              ],
            ),
            const SizedBox(height: 20),

            // 행동 버튼 (쓰다듬기, 먹이주기, 놓아주기)
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: [
                actionButton(Icons.pan_tool, "쓰다듬기", Colors.brown),
                actionButton(Icons.food_bank, "먹이주기", Colors.orange),
                actionButton(Icons.block, "놓아주기", Colors.red),
              ],
            ),
            const SizedBox(height: 20),
            Spacer(),
            // 채팅하기 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {
                  // 채팅 버튼 액션
                },
                child: const Text("채팅하기", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      
      // 하단 네비게이션 바
      // bottomNavigationBar: Bottombar(
      //   currentIndex: 0,
      //   onTabSelected: (index) {
      //     switch (index) {
      //       case 0:
      //         Navigator.pushReplacement(
      //           context,
      //           PageRouteBuilder(
      //             pageBuilder: (context, animation, secondaryAnimation) =>
      //                 HomeScreen(),
      //             transitionDuration: Duration.zero,
      //           ),
      //         );
      //         break;
      //       case 1:
      //         Navigator.pushReplacement(
      //           context,
      //           PageRouteBuilder(
      //             pageBuilder: (context, animation, secondaryAnimation) =>
      //                 HomeScreen(),
      //             transitionDuration: Duration.zero,
      //           ),
      //         );
      //         break;
      //       case 2:
      //         Navigator.pushReplacement(
      //           context,
      //           PageRouteBuilder(
      //             pageBuilder: (context, animation, secondaryAnimation) =>
      //                 HomeScreen(),
      //             transitionDuration: Duration.zero,
      //           ),
      //         );
      //         break;
      //       case 3:
      //         Navigator.pushReplacement(
      //           context,
      //           PageRouteBuilder(
      //             pageBuilder: (context, animation, secondaryAnimation) =>
      //                 MyPage(),
      //             transitionDuration: Duration.zero,
      //           ),
      //         );
      //         break;
      //     }
      //   },
      // ),
    );
  }

  // 행동 버튼 생성 함수
  Widget actionButton(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: color),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}