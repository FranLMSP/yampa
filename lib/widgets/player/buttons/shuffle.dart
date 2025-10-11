import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShuffleButton extends ConsumerWidget {
  const ShuffleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.shuffle),
      tooltip: 'Shuffle mode',
      onPressed: () async {
        print("clicked on shuffle mode");
      },
    );
  }
}
