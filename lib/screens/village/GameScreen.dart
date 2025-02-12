import 'package:flutter/material.dart';
import 'package:animalgo/screens/village/Animal.dart';
import 'dart:async';
import 'dart:math';


class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double playerX = 200;
  double playerY = 500;
  final double playerSize = 40;
  late Timer _timer;
  final Random _random = Random();

  List<Rect> blockedZones = [];
  List<Animal> _animals = [];

  @override
  void initState() {
    super.initState();
    _animals.add(Animal(x: 200, y: 200, imagePath: 'assets/images/dog1.png'));
    _animals.add(Animal(x: 300, y: 300, imagePath: 'assets/images/dog2.png'));
    _animals.add(Animal(x: 300, y: 300, imagePath: 'assets/images/dog3.png'));
    _startAutoMove();
  }

  void _startAutoMove() {
    print('왜 안움직이니');
    print(_animals);
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        double screenWidth = MediaQuery.of(context).size.width;
        double screenHeight = MediaQuery.of(context).size.height;

        blockedZones = [
          Rect.fromLTRB(0, 0, screenWidth, screenHeight * 0.1), // 첫 번째 불가능한 영역
          Rect.fromLTRB(0 * 0.5, screenHeight * 0.72, screenWidth, screenHeight), // 두 번째 불가능한 영역
        ];

        for (var animal in _animals){
          int direction = _random.nextInt(5);// 0: 왼쪽, 1: 오른쪽, 2: 위, 3: 아래
          double moveDistance = 10.0; // 이동 거리
          
          double newX = animal.x;
          double newY = animal.y;

          for (int i = 0; i<moveDistance; i++){
            print(i);
            if (direction == 0) {
              newX -= 1; // 왼쪽으로 이동
            } else if (direction == 1) {
              newX += 1; // 오른쪽으로 이동
            } else if (direction == 2) {
              newY -= 1; // 위쪽으로 이동
            } else if (direction == 3) {
              newY += 1; // 아래쪽으로 이동
            } else if (direction == 4) {
              newX = newX;
              newY = newY;
            }

            if (!_isInBlockedZone(newX, newY, animal.size)) {
              animal.x = newX.clamp(0.0, screenWidth - animal.size); // X축 범위 제한
              animal.y = newY.clamp(0.0, screenHeight - animal.size); // Y축 범위 제한
            }
          }
        }

        // // 상하좌우 랜덤으로 이동
        // int direction = _random.nextInt(5); // 0: 왼쪽, 1: 오른쪽, 2: 위, 3: 아래
        // // int direction = 3;
        // double moveDistance = 10.0; // 이동 거리

        // double newX = playerX;
        // double newY = playerY;
        // // print(direction);
        // if (direction == 0) {
        //   newX -= moveDistance; // 왼쪽으로 이동
        // } else if (direction == 1) {
        //   newX += moveDistance; // 오른쪽으로 이동
        // } else if (direction == 2) {
        //   newY -= moveDistance; // 위쪽으로 이동
        // } else if (direction == 3) {
        //   newY += moveDistance; // 아래쪽으로 이동
        // } else if (direction == 4) {
        //   newX = newX;
        //   newY = newY;
        // }

        // // 이동 후 불가능한 영역 체크
        // if (!_isInBlockedZone(newX, newY, playerSize)) {
        //   playerX = newX.clamp(0.0, screenWidth - playerSize); // X축 범위 제한
        //   playerY = newY.clamp(0.0, screenHeight - playerSize); // Y축 범위 제한
        // }
      });
    });
  }

  bool _isInBlockedZone(double x, double y, double playerSize) {
  // 플레이어의 네 변의 좌표 계산
  double left = x - playerSize;
  double right = x + playerSize;
  double top = y - playerSize;
  double bottom = y + playerSize;

  for (var zone in blockedZones) {
    if (
      zone.contains(Offset(left, y)) ||  // 왼쪽
      zone.contains(Offset(right, y)) || // 오른쪽
      zone.contains(Offset(x, top)) ||   // 위쪽
      zone.contains(Offset(x, bottom))   // 아래쪽
    ) {
      return true; // 불가능한 영역에 포함됨
    }
  }
  return false; // 불가능한 영역이 아님
}


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset("assets/images/backgroundv2.jpg", fit: BoxFit.cover),
          ),
          //  FloatingActionButton(
          //   onPressed: _getBackgroundPosition,
          //   child: Icon(Icons.info),
          // ),
          // 불가능한 영역 표시 (디버깅용)
          CustomPaint(
            size: Size.infinite,
            painter: GamePainter(blockedZones),
          ),
          ..._animals.map((animal)=>Positioned(
            left: animal.x,
            top: animal.y,
            child: Image.asset(animal.imagePath, width: animal.size, height: animal.size),
          ))
          // 캐릭터
          // Positioned(
          //   left: playerX,
          //   top: playerY,
          //   child: Image.asset("assets/images/dog1.png", width: playerSize, height: playerSize),
          // ),

          // 이동 버튼 UI
          // Positioned(
          //   bottom: 50,
          //   left: 50,
          //   child: Column(
          //     children: [
          //       IconButton(
          //         icon: Icon(Icons.arrow_drop_up, size: 50),
          //         onPressed: () => move(0, -10),
          //       ),
          //       Row(
          //         children: [
          //           IconButton(
          //             icon: Icon(Icons.arrow_left, size: 50),
          //             onPressed: () => move(-10, 0),
          //           ),
          //           SizedBox(width: 50),
          //           IconButton(
          //             icon: Icon(Icons.arrow_right, size: 50),
          //             onPressed: () => move(10, 0),
          //           ),
          //         ],
          //       ),
          //       IconButton(
          //         icon: Icon(Icons.arrow_drop_down, size: 50),
          //         onPressed: () => move(0, 10),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final List<Rect> blockedZones;

  GamePainter(this.blockedZones);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // 불가능한 영역을 그리기
    for (var zone in blockedZones) {
      canvas.drawRect(zone, paint); // 각 불가능한 영역을 빨간색으로 그리기
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}