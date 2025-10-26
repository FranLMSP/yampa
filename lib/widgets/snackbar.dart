import 'package:flutter/material.dart';

void showSnackBarMessage(
  BuildContext context,
  String message,
  {
    Color backgroundColor = Colors.red,
    Color actionTextColor = Colors.white,
    String label = 'Dismiss',
    void Function()? onPressed,
  }
) {
  // test 1
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      action: SnackBarAction(
        label: label,
        textColor: actionTextColor,
        onPressed: onPressed ?? () {},
      ),
    ),
  );
}
