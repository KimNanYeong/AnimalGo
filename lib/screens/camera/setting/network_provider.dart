import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class NetworkProvider with ChangeNotifier {
  bool _isOnline = false;
  bool _isServerConnected = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _serverCheckTimer;
  DateTime? _lastCheckTime;
  final Duration _checkInterval = Duration(minutes: 1);
  final Duration _minimumCheckInterval = Duration(seconds: 10);
  final String _serverUrl = 'http://122.46.89.124:8000';
  
  NetworkProvider() {
    _initialize();
  }

  bool get isOnline => _isOnline;
  bool get isServerConnected => _isServerConnected;
  String get serverUrl => _serverUrl;

  Future<void> _initialize() async {
    await checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
    _serverCheckTimer = Timer.periodic(_checkInterval, (_) => checkServerConnection());
    await checkServerConnection();
  }

  Future<void> checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    if (wasOnline != _isOnline) {
      notifyListeners();
      if (_isOnline) checkServerConnection();
    }
  }

  Future<bool> checkServerConnection() async {
    if (!_isOnline) return false;
    
    if (_lastCheckTime != null && 
        DateTime.now().difference(_lastCheckTime!) < _minimumCheckInterval) {
      return _isServerConnected;
    }

    try {
      _lastCheckTime = DateTime.now();
      final response = await http.get(
        Uri.parse('$_serverUrl/health'),
      ).timeout(Duration(seconds: 5));

      final wasConnected = _isServerConnected;
      _isServerConnected = response.statusCode == 200;
      
      if (wasConnected != _isServerConnected) {
        notifyListeners();
      }
      
      return _isServerConnected;
    } catch (e) {
      print('Server connection check failed: $e');
      _isServerConnected = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> isFullyConnected() async {
    return _isOnline && await checkServerConnection();
  }
  Future<http.Response> uploadImage(File imageFile) async {
    if (!await isFullyConnected()) {
      throw Exception('네트워크 연결이 불안정합니다.');
    }

    final uri = Uri.parse('$_serverUrl/segment/');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
        'Connection': 'keep-alive',
      })
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: 'image.jpg',
      ));

    final streamedResponse = await request.send().timeout(
      Duration(seconds: 30),
      onTimeout: () => throw Exception('서버 응답 시간 초과'),
    );

    return await http.Response.fromStream(streamedResponse);
  }


  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _serverCheckTimer?.cancel();
    super.dispose();
  }
}