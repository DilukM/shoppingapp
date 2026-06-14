import 'package:flutter/material.dart';

class ToastUtils {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.grey[800]!);
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.grey[800]!);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.grey[800]!);
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
