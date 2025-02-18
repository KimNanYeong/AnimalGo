import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _savePath = 'save_path';
  static const String _defaultPath = '/storage/emulated/0/Pictures/AnimalSegmentation';
  bool _isInitialized = false;

  SettingsProvider(this._prefs) {
    _initializeSettings();
  }

  bool get isInitialized => _isInitialized;
  String get savePath => _prefs.getString(_savePath) ?? _defaultPath;

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (status.isGranted) return true;

      var manageStatus = await Permission.manageExternalStorage.request();
      if (manageStatus.isGranted) return true;
    }
    return false;
  }

  Future<void> _initializeSettings() async {
    if (!_isInitialized) {
      await initializeSavePath();
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setSavePath(String path) async {
    if (await validateSavePath(path)) {
      await _prefs.setString(_savePath, path);
      notifyListeners();
    } else {
      throw Exception('Invalid save path');
    }
  }

  Future<void> resetToDefault() async {
    await setSavePath(_defaultPath);
  }

  Future<bool> initializeSavePath() async {
    if (!await requestStoragePermission()) return false;

    final directory = Directory(savePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return true;
  }

  Future<bool> validateSavePath(String path) async {
    try {
      final directory = Directory(path);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      if (!await requestStoragePermission()) {
        print('저장소 권한이 없습니다.');
        return false;
      }

      final testFile = File('${directory.path}/test.txt');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      print('Save path validation failed: $e');
      return false;
    }
  }
}
