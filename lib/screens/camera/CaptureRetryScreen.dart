import 'package:flutter/material.dart';
import 'CameraScreen.dart';

class CaptureRetryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('촬영 실패')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              '서버 응답이 없습니다. 다시 촬영해주세요.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // ✅ 다시 촬영 화면으로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => CameraScreen()),
                );
              },
              child: Text('다시 촬영하기'),
            ),
          ],
        ),
      ),
    );
  }
}
