import 'package:flutter/material.dart';

class MainPageLoader extends StatelessWidget {
  const MainPageLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Icon(
          Icons.music_note,
          color: Theme.of(context).colorScheme.primary,
          size: 120.0,
        ),
      ),
    );
  }
}
