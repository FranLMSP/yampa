import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClipButton extends ConsumerWidget {
  const ClipButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.cut),
      tooltip: 'Create audio clip',
      onPressed: () async {
        print("clicked on clip");
      },
    );
  }
}

