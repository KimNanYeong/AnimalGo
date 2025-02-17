import 'package:animalgo/components/SnackbarHelper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'FriendList.dart'; // FriendList 임포트
import '../../components/BottomBar.dart'; // BottomNavBar 컴포넌트 임포트
import '../../components/TopBar.dart'; // CustomAppBar 임포트
import '../../service/ApiService.dart';
import '../camera/CameraScreen.dart';
import '../login/LoginScreen.dart';
import '../myPage/my_page.dart';
import '../chat/ChatListScreen.dart'; // ✅ 채팅 리스트 화면 추가
import 'package:animalgo/screens/village/VillageScreen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ SharedPreferences 사용 예시

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
  // Navigater.pushReplacement(context,)

  List<Map<String, dynamic>> friends = []; // ✅ 상태로 관리할 친구 목록

  @override
  void initState() {
    super.initState();
    _checkSession();
    // _fetchFriends(); // 친구 목록 불러오기
  }

Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('cookie'); // ✅ 쿠키 값 가져오기

    if (token == null || token.isEmpty) { 
      // ✅ 토큰이 없으면 로그인 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      return;
    }

    _fetchFriends(token); // ✅ 토큰이 있으면 친구 목록 불러오기
  }

  void _fetchFriends(String token) async {
    FormData formData = FormData.fromMap({
      'user_id' : token??"1"
    });

    try{
      Dio _dio = Dio(
        BaseOptions(
          baseUrl: "http://122.46.89.124:7000", // ✅ 서버 기본 주소 설정
          connectTimeout: Duration(seconds: 10), // ✅ 연결 타임아웃 (10초)
          receiveTimeout: Duration(seconds: 10), // ✅ 응답 타임아웃 (10초)
          headers: {"Content-Type": "application/json"}, // ✅ 기본 헤더 설정
        ),
      );

      var response = await _dio.post('/home/characters',data:formData);
      if(response.statusCode==200){
        setState(() {
          Map<String,dynamic> responseMap = response.data as Map<String,dynamic>;
          List<dynamic> friendList = responseMap['characters'] ?? [];
          friends = friendList.map((friend) {
            return {
              "name": friend["nickname"],
              "image": friend["character_path"],
              "character_id" : friend["character_id"]
            };
          }).toList();
          // friends = friendList.map<Map<String,String>((friend){
          //     return {
          //       'name' : friend['nickname'],
          //       'image' : friend['character_path'],
          //       'character_id' : friend['caracter_id']
          //     }
          // });
        });
      }
    } on DioException catch(e){

    } catch(e1){
      print(e1);
      SnackbarHelper.showSnackbar(context, "서버에 오류가 발생했습니다.");
    }
    // try {
      
    //   FormData formData = FormData.fromMap({
    //     "user_id" : token
    //   });

    //   var response = await _dio.get('/home/characters',data : formData);
    //   if (response.statusCode == 200){

    //   }

    //   setState(() {
    //     Map<String,dynamic> responseMap = response as Map<String, dynamic>;
      
    //   // 2. friendList 키로 리스트 추출 (없으면 빈 리스트 사용)
    //     List<dynamic> friendList = responseMap['friendList'] ?? [];
        
//         friends = friendList.map<Map<String, String>>((friend) {
//         return {
//           "name": friend["name"] as String,
//           "image": friend["image"] as String,
//         };
//       }).toList();
//         // friends = (response as List).map((friend) {
//         //   return {
//         //     "name": friend["name"] as String,
//         //     "image": friend["image"] as String,
//         //   };
//         // }).toList();
//       });
//     } catch (error) {
//       print("친구 목록 불러오기 실패: $error");
//     }
//   }
  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // ✅ 저장된 userId 가져오기
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: Topbar(
        title: "내 친구들 (${friends.length})",
        showBackButton : false,
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
                      VillageScreen(),
                  transitionDuration: Duration.zero,
                ),
              );
              break;
            case 2: // ✅ 채팅 리스트 화면으로 이동
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ChatListScreen(), // ✅ userId 전달 제거
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
