import 'dart:async';
import 'dart:math';
import '../chat/ChatListScreen.dart';
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

    // 5개의 캐릭터를 초기 위치와 랜덤 이미지로 배치
    for (int i = 0; i < 6; i++) {
      characters.add({
        'x': random.nextDouble() * screenWidth,
        'y': random.nextDouble() * screenHeight,
        'direction': "right", // 초기 방향
        'sprite': characterSprites[random.nextInt(characterSprites.length)], // 랜덤 캐릭터 선택
      });
      isPaused.add(false); // 초기에는 모두 움직일 수 있도록 설정
    }

    // 일정 시간마다 캐릭터의 위치를 랜덤 변경 + 방향 변경
    Timer.periodic(Duration(seconds: 2), (timer) {
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

  /// ✅ 충돌한 캐릭터를 n초 동안 멈추게 함
  void _pauseCharacters(int i, int j) {
    if (!isPaused[i] && !isPaused[j]) {
      setState(() {
        isPaused[i] = true;
        isPaused[j] = true;
      });

      Future.delayed(Duration(seconds: 4), () {
        setState(() {
          isPaused[i] = false;
          isPaused[j] = false;
        });
      });
    }
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
              duration: Duration(seconds: 2),
              left: characters[i]['x']!,
              top: characters[i]['y']!,
              child: Image.asset(
                characters[i]['sprite'][characters[i]['direction']]!, // 왼쪽/오른쪽 이미지 선택
                width: 50,
                height: 50,
              ),
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
}
