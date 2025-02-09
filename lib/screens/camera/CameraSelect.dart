import 'package:flutter/material.dart';
import 'dart:io';

class CameraSelect extends StatefulWidget {
  final String segmentedImagePath; // ✅ 원본 이미지 제거, 세그멘테이션 이미지만 표시

  const CameraSelect({Key? key, required this.segmentedImagePath}) : super(key: key);

  @override
  _CameraSelectState createState() => _CameraSelectState();
}

class _CameraSelectState extends State<CameraSelect> {
  String? selectedPersonality;
  String? selectedAppearance;
  final TextEditingController nicknameController = TextEditingController();

  final List<String> personalityOptions = ['밝음', '차분함', '활발함', '조용함'];
  final List<String> appearanceOptions = ['귀여움', '멋짐', '상냥함', '강인함'];

  void _submitData() {
    String nickname = nicknameController.text;

    print('닉네임: $nickname');
    print('성격: $selectedPersonality');
    print('외모: $selectedAppearance');
    print('세그멘테이션 이미지 경로: ${widget.segmentedImagePath}');
  }

  Widget _buildImageCard(String title, String imagePath) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text('이미지를 로드할 수 없습니다'),
                        Text(error.toString(), style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('정보 입력')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 세그멘테이션된 이미지만 표시
            _buildImageCard('세그멘테이션 결과', widget.segmentedImagePath),
            const SizedBox(height: 20),

            // 닉네임 입력
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 성격 선택
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '성격 선택',
                border: OutlineInputBorder(),
              ),
              value: selectedPersonality,
              items: personalityOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPersonality = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // 외모 선택
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '외모 선택',
                border: OutlineInputBorder(),
              ),
              value: selectedAppearance,
              items: appearanceOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedAppearance = newValue;
                });
              },
            ),
            const SizedBox(height: 20),

            // 제출 버튼
            Center(
              child: ElevatedButton(
                onPressed: _submitData,
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
