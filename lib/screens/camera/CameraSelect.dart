import 'package:flutter/material.dart';
import 'dart:io';

class CameraSelect extends StatefulWidget {
  final String imagePath;

  const CameraSelect({Key? key, required this.imagePath}) : super(key: key);

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
    print('이미지 경로: ${widget.imagePath}');

    // 여기에 서버 전송이나 데이터 저장 로직 추가 가능
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('정보 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 촬영한 이미지 표시
            Center(
              child: Image.file(
                File(widget.imagePath),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // 2. 닉네임 입력 텍스트박스
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 3. 성격 선택 콤보박스
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

            // 4. 외모 선택 콤보박스
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

            // 5. 제출 버튼
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
