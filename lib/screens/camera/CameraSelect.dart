import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'setting/settings_provider.dart';

class CameraSelect extends StatefulWidget {
  final String segmentedImagePath; // ✅ 세그멘테이션 이미지 경로

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

  /// ✅ 저장 함수
  Future<void> _saveData() async {
    final nickname = nicknameController.text.trim();
    if (nickname.isEmpty || selectedPersonality == null || selectedAppearance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임, 성격, 외모를 모두 입력하세요.'))
      );
      return;
    }

    try {
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      // 저장할 폴더 가져오기
      String saveDirectory = settingsProvider.savePath;
      if (!await settingsProvider.validateSavePath(saveDirectory)) {
        print('저장 경로 검증 실패. 기본 경로 사용');
        saveDirectory = '/storage/emulated/0/Pictures/AnimalSegmentation';
      }

      // 폴더가 없으면 생성
      final directory = Directory(saveDirectory);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 저장할 파일 경로 설정
      final String saveFileName = 'segmented_${DateTime.now().millisecondsSinceEpoch}.png';
      final String saveFilePath = path.join(saveDirectory, saveFileName);
      
      // 기존 이미지 파일을 새로운 위치로 복사
      final File originalFile = File(widget.segmentedImagePath);
      await originalFile.copy(saveFilePath);

      print('저장 성공: $saveFilePath');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 저장 완료! \n위치: $saveFilePath'))
      );
      
      Navigator.pop(context); // 저장 후 이전 화면으로 이동
    } catch (e) {
      print('파일 저장 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 저장 실패: $e'), backgroundColor: Colors.red)
      );
    }
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

            // ✅ 저장 버튼 (저장 함수 호출)
            Center(
              child: ElevatedButton(
                onPressed: _saveData,
                child: const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
