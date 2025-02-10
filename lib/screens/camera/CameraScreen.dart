import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'CameraSelect.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      // 촬영된 이미지 사용 가능
      print("사진 촬영 완료: ${image.path}");
      Navigator.pop(context, image.path);// 이전 화면으로 이미지 경로 반환
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraSelect(imagePath: image.path)),
      );
    } else {
      print("촬영 취소됨");
      Navigator.pop(context); // 촬영 취소 시 이전 화면으로 돌아가기
    }
  }

  @override
  void initState() {
    super.initState();
    _openCamera(); // 화면이 열리자마자 카메라 실행
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("카메라 촬영")),
      // body: Center(child: Text("카메라를 준비 중입니다...")),
    );
  }
}
