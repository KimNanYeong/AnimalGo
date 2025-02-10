// camera_screen.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'CameraSelect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'setting/network_provider.dart';
import 'setting/settings_provider.dart';
// import 'setting/animal_characteristics_provider.dart';

// 카메라 화면을 담당하는 StatefulWidget
class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isDisposed = false;
  bool _isProcessing = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  bool _isFlashOn = false;
  bool _isCameraInitialized = false;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }
  // 앱 상태가 변경될 때 호출되는 함수 (예: 앱이 백그라운드로 갈 때)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }
  // 카메라 리소스를 정리하는 함수
  Future<void> _disposeCamera() async {
    if (_controller != null) {
      await _controller!.dispose();
      if (!_isDisposed) {
        setState(() => _controller = null);
      }
    }
  }
  // 카메라를 초기화하는 함수
  Future<void> _initializeCamera() async {
    if (!await _checkCameraPermission()) {
      setState(() {
        _errorMessage = '카메라 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
        _isCameraInitialized = false;
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('No cameras', '사용 가능한 카메라가 없습니다');

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _controller = controller;

      // 컨트롤러 초기화
      await controller.initialize();
      if (!_isDisposed) {
        setState(() {
          _isCameraInitialized = true;
          _errorMessage = null;
        });
      }

      // 카메라 설정 구성
      await _configureCameraSettings(controller);

    } catch (e) {
      print('카메라 초기화 오류: $e');
      if (!_isDisposed) {
        setState(() {
          _errorMessage = '카메라 초기화 실패: $e';
          _isCameraInitialized = false;
        });
      }
    }
  }
  // 이미지를 압축하는 함수
  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,  // 품질 향상
        format: CompressFormat.jpeg,
        keepExif: true,
      );

      if (result == null) throw Exception('이미지 압축 실패');
      return File(result.path);
    } catch (e) {
      print('[압축 에러] ${DateTime.now()}: $e');
      return null;
    }
  }
  // 오류 메시지를 화면에 표시하는 함수
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
  // 카메라 권한 확인 함수
  Future<bool> _checkCameraPermission() async {
    return await Permission.camera.request().isGranted;
  }
  // 사진을 촬영하고 처리하는 함수
  Future<void> _captureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      // 촬영 전 카메라 상태 확인
      if (!_controller!.value.isInitialized) {
        throw CameraException('카메라 미초기화', '카메라가 초기화되지 않았습니다.');
      }

      final XFile picture = await _controller!.takePicture();

      // 임시 파일로 저장
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(tempDir.path, 'temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(picture.path).copy(tempPath);

      if (!mounted) return;

      // 서버 전송 처리
      await _processImage(File(tempPath));

      setState(() {
        _isProcessing = false;
        _errorMessage = '사진 다시 찍어주세요'; // 📌 오류 발생 시 메시지 설정
      });

    } catch (e) {
      print('촬영 오류: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('촬영 중 오류가 발생했습니다: $e')),
      );
    }
  }
  // 플래시 토글 함수
  void _toggleFlash() async {
    if (_controller != null) {
      try {
        setState(() => _isFlashOn = !_isFlashOn);
        await _controller!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off,
        );
      } catch (e) {
        print('플래시 토글 실패: $e');
      }
    }
  }
  // ✅ 서버 전송 후 가공된 이미지 수신 후 삭제
  Future<void> _processImage(File imageFile) async {
    final networkProvider = Provider.of<NetworkProvider>(context, listen: false);

    if (!await networkProvider.isFullyConnected()) {
      throw Exception('서버 연결이 불안정합니다. 네트워크 상태를 확인해주세요.');
    }

    try {
      final compressedFile = await _compressImage(imageFile);
      if (compressedFile == null) throw Exception('이미지 압축 실패');

      final response = await networkProvider.uploadImage(compressedFile);

      if (response.statusCode == 200) {
        print('이미지 서버 업로드 성공');

        final decodedData = json.decode(response.body);
        if (!decodedData.containsKey('image')) {
          throw Exception('서버 응답에 세그멘테이션 이미지 없음');
        }

        // ✅ 서버에서 가공된 이미지 수신
        final imageBytes = base64Decode(decodedData['image']);
        final tempDir = await getTemporaryDirectory();
        final segmentedPath = path.join(tempDir.path, 'segmented_${DateTime.now().millisecondsSinceEpoch}.png');

        File segmentedFile = File(segmentedPath);
        await segmentedFile.writeAsBytes(imageBytes);
        print('세그멘테이션 이미지 저장 완료: $segmentedPath');

        // ✅ 가공된 이미지 수신 후 원본 이미지 삭제
        await compressedFile.delete();
        await imageFile.delete();
        print('원본 및 압축된 이미지 삭제 완료');

        // ✅ CameraSelect 화면으로 이동 (여기서만 저장 가능)
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CameraSelect(segmentedImagePath: segmentedPath),
            ),
          );
        }
      } else {
        print('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('[에러] 이미지 처리 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 처리 실패: $e')),
      );
    }
  }
  // 카메라 설정을 적용하는 함수
  Future<void> _configureCameraSettings(CameraController controller) async {
    try {
      await Future.wait([
        controller.setFlashMode(FlashMode.off),
        controller.setExposureMode(ExposureMode.auto),
        controller.setFocusMode(FocusMode.auto),
      ]);
    } catch (e) {
      print('Camera settings error: $e');
    }
  }
  @override
  void dispose() {
    _isDisposed = true;
    _disposeCamera();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('카메라'),
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
          Consumer<NetworkProvider>(
            builder: (context, network, child) => Icon(
              network.isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: network.isOnline ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // ✅ '다시 찍어주세요' 버튼 클릭 시 사진촬영 모드로 이동
                setState(() {
                  _errorMessage = null; // 오류 메시지 초기화
                  _initializeCamera(); // 카메라 다시 초기화
                });
              },
              child: Text('다시 찍어주세요'),
            ),
          ],
        ),
      );
    }


    if (!_isCameraInitialized || _controller == null || !_controller!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('카메라 초기화 중...'),
          ],
        ),
      );
    }

    return Stack(
      children: [
        CameraPreview(_controller!),
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '처리 중... ${(_uploadProgress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: FloatingActionButton(
              onPressed: _isProcessing ? null : _captureAndProcess,
              child: Icon(_isProcessing ? Icons.hourglass_empty : Icons.camera),
              backgroundColor: _isProcessing ? Colors.grey : null,
            ),
          ),
        ),
      ],
    );
  }
}