import 'package:flutter/material.dart';
import 'FriendList.dart'; // FriendList 임포트
import '../../components/BottomBar.dart'; // BottomNavBar 컴포넌트 임포트
import '../../components/TopBar.dart'; // CustomAppBar 임포트
import '../../service/ApiService.dart';
import '../camera/CameraScreen.dart';

// class HomeScreen extends StatelessWidget {
//   final List<Map<String, String>> friends = [
//     {"name": "복실이", "image": "assets/images/dog1.png"},
//     {"name": "별이", "image": "assets/images/dog2.png"},
//     {"name": "초코", "image": "assets/images/dog3.png"},
//     {"name": "구름", "image": "assets/images/dog1.png"},
//     {"name": "해피", "image": "assets/images/dog2.png"},
//     {"name": "뽀삐", "image": "assets/images/dog3.png"},
//     {"name": "토리", "image": "assets/images/dog1.png"},
//     {"name": "루루", "image": "assets/images/dog2.png"},
//   ];

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> friends = []; // ✅ 상태로 관리할 친구 목록
  

  @override
  void initState() {
    super.initState();
    _fetchFriends(); // 친구 목록 불러오기
  }

  void _fetchFriends() async {
    try {
      var response = await ApiService().get(
        "/friends",
        params: {"userId": "1234"},
      );

      setState(() {
        Map<String,dynamic> responseMap = response as Map<String, dynamic>;
      
      // 2. friendList 키로 리스트 추출 (없으면 빈 리스트 사용)
        List<dynamic> friendList = responseMap['friendList'] ?? [];
        
        friends = friendList.map<Map<String, String>>((friend) {
        return {
          "name": friend["name"] as String,
          "image": friend["image"] as String,
        };
      }).toList();
        // friends = (response as List).map((friend) {
        //   return {
        //     "name": friend["name"] as String,
        //     "image": friend["image"] as String,
        //   };
        // }).toList();
      });
    } catch (error) {
      print("친구 목록 불러오기 실패: $error");
    }
  }

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CameraScreen()),
          );
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
