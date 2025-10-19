import 'package:flutter/material.dart';

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