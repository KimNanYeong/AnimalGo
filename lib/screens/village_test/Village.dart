import 'dart:async';
import 'dart:math';
import '../chat/ChatListScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import '../myPage/my_page.dart';
import '../home/HomeScreen.dart';
import '../../components/BottomBar.dart';

class VillageScreen extends StatefulWidget {
  @override
  _VillageScreenState createState() => _VillageScreenState();
}

class _VillageScreenState extends State<VillageScreen> {
  final Random random = Random();
  final double screenWidth = 360; // 배경 사이즈 (가로)
  final double screenHeight = 600; // 배경 사이즈 (세로)

  double characterX = 0;
  double characterY = 0;
  double speed = 5.0;

  List<Map<String, dynamic>> characters = [];
  List<bool> isPaused = []; // 캐릭터 멈춤 여부
  List<Map<String, dynamic>> speechBubbles = []; // 말풍선 리스트

  // ✅ 사용할 여러 개의 캐릭터 이미지 (왼쪽/오른쪽 방향)
  final List<Map<String, String>> characterSprites = [
    {"left": "assets/images/cat_left.png", "right": "assets/images/cat_right.png"},
    {"left": "assets/images/cow_left.png", "right": "assets/images/cow_right.png"},
    {"left": "assets/images/dog_left.png", "right": "assets/images/dog_right.png"},
    {"left": "assets/images/bear_left.png", "right": "assets/images/bear_right.png"},
    {"left": "assets/images/horse_left.png", "right": "assets/images/horse_right.png"},
    {"left": "assets/images/zebra_left.png", "right": "assets/images/zebra_right.png"}
  ];

  @override
  void initState() {
    super.initState();

    // 5개의 캐릭터를 초기 위치와 이미지로 배치
    for (int i = 0; i < 6; i++) {
      characters.add({
        'x': random.nextDouble() * screenWidth,
        'y': random.nextDouble() * screenHeight,
        'direction': "right", // 초기 방향
        'sprite': characterSprites[i], // 캐릭터
      });
      isPaused.add(false); // 초기에는 모두 움직일 수 있도록 설정
    }

    // 일정 시간마다 캐릭터의 위치를 랜덤 변경 + 방향 변경
    Timer.periodic(Duration(seconds: random.nextInt(6) + 3), (timer) {// 3~8초 랜덤
      setState(() {
        for (int i = 0; i < characters.length; i++) {
          if (!isPaused[i]) { // 멈춰있는 캐릭터는 이동하지 않음
            double newX = random.nextDouble() *
                (screenWidth - 50); // 50은 캐릭터 크기
            double newY = random.nextDouble() * (screenHeight - 50);

            // 방향 결정 (왼쪽/오른쪽 비교)
            String newDirection = newX < characters[i]['x'] ? "left" : "right";

            characters[i]['x'] = newX;
            characters[i]['y'] = newY;
            characters[i]['direction'] = newDirection;
          }
        }
        // 충돌 감지
        _checkCollisions();
      });
    });
  }
  void _updatePosition(StickDragDetails details) {
    setState(() {
      characterX += details.x * speed;
      characterY += details.y * speed;
    });
  }
  /// ✅ 충돌 감지 및 멈춤 처리
  void _checkCollisions() {
    for (int i = 0; i < characters.length; i++) {
      for (int j = i + 1; j < characters.length; j++) {
        if (_isColliding(i, j)) {
          _pauseCharacters(i, j);
        }
      }
    }
  }
  /// ✅ 두 캐릭터가 충돌했는지 확인
  bool _isColliding(int i, int j) {
    double dx = (characters[i]['x']! - characters[j]['x']!).abs();
    double dy = (characters[i]['y']! - characters[j]['y']!).abs();
    return dx < 50 && dy < 50; // 캐릭터 크기(50px) 이내면 충돌
  }
  /// ✅ 충돌한 캐릭터를 n초 동안 멈추게 한 후, 말풍선 표시
  void _pauseCharacters(int i, int j) {
    if (!isPaused[i] && !isPaused[j]) {
      setState(() {
        isPaused[i] = true;
        isPaused[j] = true;
      });
      // ✅ 충돌 후 n초 동안 멈추게 함 (6초)
      Future.delayed(Duration(seconds: 6), () {
        setState(() {
          isPaused[i] = false;
          isPaused[j] = false;
          _showSpeechBubbles(i, j);
        });
      });
    }
  }
  /// ✅ 충돌 시 두 캐릭터 모두 말풍선을 띄우도록 수정
  void _showSpeechBubbles(int i, int j) {
    String bubbleId1 = "${i}_${DateTime.now().millisecondsSinceEpoch}"; // 캐릭터 1의 말풍선 ID
    String bubbleId2 = "${j}_${DateTime.now().millisecondsSinceEpoch}"; // 캐릭터 2의 말풍선 ID

    List<String> messages = ["안녕!", "반가워!", "좋은 날이야!", "뭐해?", "같이 놀자!", "재밌겠다!"];
    String message1 = messages[random.nextInt(messages.length)];
    String message2 = messages[random.nextInt(messages.length)];

    setState(() {
      speechBubbles.add({
        'id': bubbleId1,
        'x': characters[i]['x'], // 첫 번째 캐릭터 위치
        'y': characters[i]['y'] - 40,
        'message': message1, // 말풍선 메시지
      });
      speechBubbles.add({
        'id': bubbleId2,
        'x': characters[j]['x'], // 두 번째 캐릭터 위치
        'y': characters[j]['y'] - 40,
        'message': message2, // 말풍선 메시지
      });
    });

    // ✅ n초 후 말풍선 삭제
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        speechBubbles.removeWhere((bubble) => bubble['id'] == bubbleId1 || bubble['id'] == bubbleId2);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("마을")),
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg', // 배경 이미지
              fit: BoxFit.cover,
            ),
          ),
          // ✅ 캐릭터 (파란색 원)
          Positioned(
            left: characterX + MediaQuery.of(context).size.width / 2 - 25,
            top: characterY + MediaQuery.of(context).size.height / 2 - 25,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // ✅ Joystick 추가 (화면 왼쪽 하단)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: SizedBox(
                width: 80, // ✅ 조이스틱 크기 조절 (기본값보다 작게)
                height: 80,
                child: Joystick(
                  mode: JoystickMode.all, // 모든 방향 가능 (상하좌우 + 대각선)
                  listener: (details) {
                    _updatePosition(details);
                  },
                ),
              ),
            ),
          ),


          // 캐릭터들을 랜덤하게 배치
          for (int i = 0; i < characters.length; i++)
            AnimatedPositioned(
              duration: Duration(seconds: 6),
              left: characters[i]['x']!,
              top: characters[i]['y']!,
              child: Image.asset(
                characters[i]['sprite'][characters[i]['direction']]!, // 왼쪽/오른쪽 이미지 선택
                width: 50,
                height: 50,
              ),
            ),
          // ✅ 말풍선 추가
          for (var bubble in speechBubbles)
            Positioned(
              left: bubble['x'],
              top: bubble['y'],
              child: _buildSpeechBubble(bubble['message']),
            ),
        ],

      ),

      bottomNavigationBar: Bottombar(
        currentIndex: 1,
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
  /// ✅ 말풍선 UI
  Widget _buildSpeechBubble(String message) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
  ///✅ 말풍선 UI
  // Widget _Joystick_menual(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: Stack(
  //       children: [
  //         // ✅ 캐릭터 (파란색 원)
  //         Positioned(
  //           left: characterX + MediaQuery.of(context).size.width / 2 - 25,
  //           top: characterY + MediaQuery.of(context).size.height / 2 - 25,
  //           child: Container(
  //             width: 50,
  //             height: 50,
  //             decoration: BoxDecoration(
  //               color: Colors.blue,
  //               shape: BoxShape.circle,
  //             ),
  //           ),
  //         ),
  //
  //         // ✅ Joystick 추가 (화면 왼쪽 하단)
  //         Align(
  //           alignment: Alignment.bottomLeft,
  //           child: Padding(
  //             padding: const EdgeInsets.all(32.0),
  //             child: Joystick(
  //               mode: JoystickMode.all, // 모든 방향 가능 (상하좌우 + 대각선)
  //               listener: (details) {
  //                 _updatePosition(details);
  //               },
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
