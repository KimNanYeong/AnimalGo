import 'package:flutter/material.dart';

class DeleteAccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white,title: Text('회원탈퇴')),
      body: Center(child: Text('회원탈퇴 안내 및 확인 버튼 추가')),
    );
  }
}
