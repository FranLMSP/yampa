import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/widgets/main_page_loader.dart';
import 'package:music_player/widgets/player/big_player.dart';
import 'package:music_player/widgets/track_pickers/local_path_picker.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YAMPA - Yet Another Music Player App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  bool _hasFinishedLoading = false;

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });
    // Simulate loading delay
    // await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      _hasFinishedLoading = true;
    });
  }

  Widget _buildMainPageLoader() {
    return const MainPageLoader();
  }

  Widget _buildMainContent() {
    return const Scaffold(
      body: Center(
        child: Row(
          children: [
            // temp file picker here
            SizedBox(
              width: 300,
              child: LocalPathPicker(),
            ),
            // main player here?
            // TODO: pass current track from provider
            Expanded(
              child: Center(
                child: BigPlayer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasFinishedLoading) {
      _load();
    }
    return _isLoading
        ? _buildMainPageLoader()
        : _buildMainContent();
  }
}
