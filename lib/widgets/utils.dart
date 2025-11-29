import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum ViewMode {
  portrait,
  landscape,
  desktop,
}

ViewMode getViewMode(BoxConstraints constraints) {
  if (constraints.maxWidth <= 800) {
    return ViewMode.portrait;
  }
  return ViewMode.landscape;
}

Future<void> showButtonActionMessage(String message) async {
  if (Platform.isAndroid || Platform.isIOS) {
    await Fluttertoast.cancel();
    await Fluttertoast.showToast(
        msg: message,
    );
  }
}
