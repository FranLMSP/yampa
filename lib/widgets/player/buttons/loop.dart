import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoopButton extends ConsumerWidget {
  const LoopButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.loop),
      tooltip: 'Loop mode',
      onPressed: () async {
        print("clicked on loop mode");
      },
    );
  }
}
