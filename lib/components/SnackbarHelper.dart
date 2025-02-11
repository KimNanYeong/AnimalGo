import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
