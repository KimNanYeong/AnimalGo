import 'package:flutter/material.dart';
import 'SocialLoginButton.dart';
import '../regist/RegistScreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '아이디',
                ),
              ),
              const SizedBox(height: 20),
              // 패스워드 입력 필드
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '패스워드',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              // 로그인 버튼
              ElevatedButton(
                onPressed: () {},
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

