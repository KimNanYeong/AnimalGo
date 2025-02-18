import 'package:flutter/material.dart';
import 'package:animalgo/screens/home/HomeScreen.dart';
import 'package:animalgo/screens/myPage/my_page.dart';
import 'package:animalgo/components/BottomBar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CharacterScreen extends StatefulWidget{
  final String character_id;
  // const CharacterScreen({Key? key}) : super(key: key);
  const CharacterScreen({
    Key? key,
    required this.character_id,
    // required this.imageUrl
  }) : super(key: key);

  @override
  _CharacterscreenState createState() => _CharacterscreenState();
}

class _CharacterscreenState extends State<CharacterScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // title: const Text("상세보기"),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 30,
              // backgroundImage: AssetImage("assets/images/dog1.png"), // 프로필 이미지
              backgroundImage: NetworkImage(
                '${dotenv.env['SERVER_URL']}/image/show_image?character_id=${widget.character_id}&type=original',
              ),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Colors.transparent, // 배경 투명
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context), // 탭하면 닫힘
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(
                              '${dotenv.env['SERVER_URL']}/image/show_image?character_id=${widget.character_id}&type=original}'
                            ),
                            fit: BoxFit.contain, // 원본 비율 유지
                          ),
                        ),
                        width: MediaQuery.of(context).size.width * 0.8, // 화면의 80% 크기
                        height: MediaQuery.of(context).size.height * 0.5, // 화면의 50% 크기
                      ),
                    ),
                  );
                },
              );
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
                CircleAvatar(
                  radius: 60,
                   backgroundImage: NetworkImage(
                    '${dotenv.env['SERVER_URL']}/image/show_image?character_id=${widget.character_id}&type=original',
                  ),
                  
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          "닉네임",
                          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
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
              physics: NeverScrollableScrollPhysics(),
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