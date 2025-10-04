import 'package:flutter/material.dart';

void showSnackBarMessage(
  BuildContext context,
  String message,
  {
    Color backgroundColor = Colors.red,
    Color textColor = Colors.red,
    String label = 'Dismiss',
    void Function()? onPressed,
  }
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      action: SnackBarAction(
        label: label,
        textColor: textColor,
        onPressed: onPressed ?? () {},
      ),
    ),
  );
}
