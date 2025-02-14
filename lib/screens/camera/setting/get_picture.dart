import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageFromServer extends StatefulWidget {
  @override
  _ImageFromServerState createState() => _ImageFromServerState();
}

class _ImageFromServerState extends State<ImageFromServer> {
  Uint8List? imageData; // 이미지 데이터를 저장할 변수

  @override
  void initState() {
    super.initState();
    fetchImage(); // 서버에서 이미지 가져오기 실행
  }

  Future<void> fetchImage() async {
    final String baseUrl = "http://122.46.89.124:7000/image/show_image";
    final String characterId = "1_a";  // 서버에서 받아올 캐릭터 ID
    final String type = "character";   // 기본값 (original 또는 character 가능)

    final Uri uri = Uri.parse("$baseUrl?character_id=$characterId&type=$type");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          imageData = response.bodyBytes; // 바이트 데이터를 저장하여 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미지를 확인하세요')),
          );
        });
      } else {
        print("❌ 이미지 다운로드 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ 에러 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("서버에서 이미지 가져오기")),
      body: Center(
        child: imageData == null
            ? CircularProgressIndicator() // 이미지 로딩 중
            : Image.memory(imageData!), // 이미지 표시
      ),
    );
  }
}
