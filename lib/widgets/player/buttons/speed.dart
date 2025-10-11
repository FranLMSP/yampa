import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpeedButton extends ConsumerWidget {
  const SpeedButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Chip(
      label: Text('x1'),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
