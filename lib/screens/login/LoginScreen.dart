import 'package:flutter/material.dart';
import 'SocialLoginButton.dart';
import '../regist/RegistScreen.dart';
import '../../service/ApiService.dart';
import '../../components/SnackbarHelper.dart';
import '../home/HomeScreen.dart';

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState(){
    _idFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose(){
    _idFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _login() async {
    final String id = _idController.text;
    final String password = _passwordController.text;

    if (id.isEmpty){
      SnackbarHelper.showSnackbar(context, '아이디를 입력해주세요.');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     duration: Duration(seconds: 1),
      //     content: Text(
      //       '아이디를 입력해주세요.',
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontSize: 16,
      //         ),
      //         textAlign: TextAlign.center,
      //       ),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      return;
    }

    if (password.isEmpty){
      SnackbarHelper.showSnackbar(context, "비밀번호를 입력해주세요.");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     duration: Duration(seconds: 1),
      //     content: Text(
      //       '비밀번호를 입력해주세요.',
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontSize: 16,
      //         ),
      //         textAlign: TextAlign.center,
      //       ),
      //     backgroundColor: Colors.red,
      //   ),
      // );
      // return;
    }

    try {
      var response = await ApiService().post(
        '/login',
        data: {
          'id': id,
          'password': password,
        },
      );

      if (response['result'] == false){
        SnackbarHelper.showSnackbar(context, '아이디 또는 비밀번호가 일치하지 않습니다.');
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     duration: Duration(seconds: 1),
        //     content: Text(
        //       '아이디 또는 비밀번호가 일치하지 않습니다.',
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontSize: 16,
        //         ),
        //         textAlign: TextAlign.center,
        //       ),
        //     backgroundColor: Colors.red,
        //   ),
        // );
        return;
      }

      Navigator.push(
              context,
              // 'HomeScreen' // MaterialPageRoute(builder: (context) => HomeScreen()
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
              //   transitionDuration: Duration(milliseconds: 100), // 0.5초 애니메이션 지속
              //   transitionsBuilder: (context, animation, secondaryAnimation, child) {
              //     return FadeTransition(
              //       opacity: animation, // 애니메이션 효과 적용
              //       child: child,
              //     );
              //   },
              )
      );
    } catch (e){
      print('로그인 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading:  IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pushReplacement( // 이전 화면으로 이동
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        HomeScreen(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            )
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ANIMAL GO',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // 아이디 입력 필드
              TextField(
                controller: _idController,
                focusNode: _idFocusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '아이디',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 패스워드 입력 필드
              TextField(
                controller: _passwordController,
                focusNode : _passwordFocusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '패스워드',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 40),
              // 로그인 버튼
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // 로그인 버튼의 border radius
                  ),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(color: Colors.white),
                ),
              ),
               const SizedBox(height: 20),
              // 회원가입
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // 로그인 버튼의 border radius
                    side : BorderSide(color: const Color.fromARGB(255, 190, 190, 190), width: 1.0)
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(color: Colors.black),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              SocialLoginButton(
                iconPath: 'assets/images/google.webp',
                label: 'Sign in with Google',
                onPressed: () {

                },
              ),
              const SizedBox(height: 10),
              SocialLoginButton(
                iconPath: 'assets/images/naver.png',
                label: 'Sign in with Naver',
                onPressed: () {

                },
              ),
              const SizedBox(height: 10),
              SocialLoginButton(
                iconPath: 'assets/images/kakao.png',
                label: 'Sign in with Kakao',
                onPressed: () {

                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// class _LoginScreenState extends State<LoginScreen> {
//   // const LoginScreen({Key? key}) : super(key: key);

//   final FocusNode _idFocusNode = FocusNode();
//   final FocusNode _passwordFocusNode = FocusNode();

  

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white, elevation: 0,
//         leading:  IconButton(
//               icon: Icon(Icons.arrow_back, color: Colors.black),
//               onPressed: () {
//                 Navigator.pop(context); // 이전 화면으로 이동
//               },
//             )
//       ),
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 'ANIMAL GO',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               // 아이디 입력 필드
//               TextField(
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: '아이디',
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // 패스워드 입력 필드
//               TextField(
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   hintText: '패스워드',
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.black),
//                   ),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 20),
//               // 로그인 버튼
//               ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4), // 로그인 버튼의 border radius
//                   ),
//                 ),
//                 child: const Text(
//                   '로그인',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ),
//                const SizedBox(height: 20),
//               // 회원가입
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => RegistScreen()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(4), // 로그인 버튼의 border radius
//                     side : BorderSide(color: const Color.fromARGB(255, 190, 190, 190), width: 1.0)
//                   ),
//                 ),
//                 child: const Text(
//                   '회원가입',
//                   style: TextStyle(color: Colors.black),
//                 ),
//               ),

//               const SizedBox(height: 20),
//               const Divider(),
//               const SizedBox(height: 10),
//               SocialLoginButton(
//                 iconPath: 'assets/images/google.webp',
//                 label: 'Sign in with Google',
//                 onPressed: () {

//                 },
//               ),
//               const SizedBox(height: 10),
//               SocialLoginButton(
//                 iconPath: 'assets/images/naver.png',
//                 label: 'Sign in with Naver',
//                 onPressed: () {

//                 },
//               ),
//               const SizedBox(height: 10),
//               SocialLoginButton(
//                 iconPath: 'assets/images/kakao.png',
//                 label: 'Sign in with Kakao',
//                 onPressed: () {

//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

