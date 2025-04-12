import 'package:flutter/material.dart';
import 'package:fyp_wyc/main.dart';

class MySnackBar {
  static void showSnackBar(String message, {
    bool undoable = false,
    VoidCallback? onUndo,
  }) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        action: undoable && onUndo != null
            ? SnackBarAction(
                label: 'Undo',
                onPressed: onUndo,
              )
            : null,
      ),
    );
  }
}
