import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/widgets/player/player_buttons.dart';
import 'package:music_player/widgets/track_pickers/local_path_picker.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            // temp file picker here
            SizedBox(
              width: 300,
              child: LocalPathPicker(),
            ),
            // main player here?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlayerButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
