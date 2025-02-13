import 'dart:async';
import 'dart:math';
import 'package:animalgo/screens/chat/ChatListScreen.dart';
import 'package:flutter/material.dart';
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
    Timer.periodic(Duration(seconds: 5), (timer) {
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
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          isPaused[i] = false;
          isPaused[j] = false;
          _showSpeechBubble(i, j);
        });
      });
    }
  }
  /// ✅ 충돌 시 말풍선 표시 (n초 후 사라짐)
  void _showSpeechBubble(int i, int j) {
    String bubbleId = "${i}_${j}_${DateTime.now().millisecondsSinceEpoch}"; // 말풍선 고유 ID 생성

    setState(() {
      speechBubbles.add({
        'id': bubbleId, // 고유 ID 추가
        'x': (characters[i]['x']! + characters[j]['x']!) / 2, // 두 캐릭터 중앙
        'y': (characters[i]['y']! + characters[j]['y']!) / 2 - 40, // 캐릭터 위쪽에 표시
        'message': "안녕!", // 말풍선 메시지
      });
    });

    // ✅ n초 후 말풍선 삭제
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        speechBubbles.removeWhere((bubble) => bubble['id'] == bubbleId);
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

          // 캐릭터들을 랜덤하게 배치
          for (int i = 0; i < characters.length; i++)
            AnimatedPositioned(
              duration: Duration(seconds: 5),
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
}
