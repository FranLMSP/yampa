import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class ClipButton extends ConsumerWidget {
  const ClipButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.cut),
      tooltip: ref
          .read(localizationProvider.notifier)
          .translate(LocalizationKeys.createAudioClip),
      onPressed: () async {
        debugPrint("clicked on clip");
      },
    );
  }
}
