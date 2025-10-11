import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return IconButton(
      icon: const Icon(Icons.favorite),
      tooltip: 'Saved to favorites',
      onPressed: () async {
        print("clicked on favorite");
      },
    );
  }
}


