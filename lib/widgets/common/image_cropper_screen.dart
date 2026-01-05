import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yampa/providers/localization_provider.dart';
import 'package:yampa/core/localization/keys.dart';

class ImageCropperScreen extends ConsumerStatefulWidget {
  final Uint8List imageData;

  const ImageCropperScreen({super.key, required this.imageData});

  @override
  ConsumerState<ImageCropperScreen> createState() => _ImageCropperScreenState();
}

class _ImageCropperScreenState extends ConsumerState<ImageCropperScreen> {
  final _controller = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ref.read(localizationProvider.notifier).translate(LocalizationKeys.cropImage)),
        actions: [
          if (_isCropping)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              onPressed: () {
                setState(() {
                  _isCropping = true;
                });
                _controller.crop();
              },
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox.expand(
            child: Crop(
              key: ValueKey(constraints),
              image: widget.imageData,
              controller: _controller,
              onCropped: (result) {
                if (mounted) {
                  if (result is CropSuccess) {
                    Navigator.of(context).pop(result.croppedImage);
                  } else {
                    // Handle failure or do nothing
                    // Optionally show an error message
                    setState(() {
                      _isCropping = false;
                    });
                  }
                }
              },
              aspectRatio: 1,
              // Ensure the crop area is always visible and usable
              baseColor: Colors.black.withValues(alpha: 0.8),
              maskColor: Colors.black.withValues(alpha: 0.4),
              progressIndicator: const CircularProgressIndicator(),
              radius: 0,
              interactive: true,
            ),
          );
        },
      ),
    );
  }
}
