import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../greenthumb/service.dart';
import '../platform_util.dart';
import '../styles.dart';
import '../view_models/view_model.dart';
import '../widgets/gt_button.dart';

class InterruptImagePicker extends StatefulWidget {
  InterruptImagePicker({
    required this.message,
    required this.onResume,
    super.key,
  }) : assert(message.toolResponse == null || onResume == null),
       selectedImage =
           message.toolResponse?.output != null
               ? base64Decode(message.toolResponse!.output.split(',').last)
               : null;

  final InterruptMessage message;
  final Uint8List? selectedImage;
  final ToolResumeCallback? onResume;

  @override
  State<InterruptImagePicker> createState() => _InterruptImagePickerState();
}

class _InterruptImagePickerState extends State<InterruptImagePicker> {
  Uint8List? _currentImageBytes;
  var _isCompressing = false;

  @override
  void initState() {
    super.initState();
    _currentImageBytes = widget.selectedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentImageBytes == null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.extraLargePadding,
            ),
            child: Text(
              widget.message.text,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
        if (_currentImageBytes == null)
          SizedBox(height: AppLayout.largePadding),
        if (_currentImageBytes == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppLayout.extraLargePadding,
              ),
              child: Row(
                children: [
                  Spacer(),
                  GtButton(
                    style: GtButtonStyle.outlined,
                    onPressed:
                        _isCompressing || widget.onResume == null
                            ? null
                            : () => _skipPhoto(),
                    child: const Text('Skip'),
                  ),
                  SizedBox(width: 10),
                  GtButton(
                    style:
                        _currentImageBytes == null
                            ? GtButtonStyle.elevated
                            : GtButtonStyle.outlined,
                    onPressed:
                        _isCompressing || widget.onResume == null
                            ? null
                            : () => _getPicture(context),
                    child: const Text('Select picture'),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        if (_currentImageBytes != null)
          SizedBox(height: AppLayout.defaultPadding),
        if (_currentImageBytes != null)
          Text('Use this image?', style: AppTextStyles.body),
        if (_currentImageBytes != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                _currentImageBytes!,
                fit: BoxFit.cover,
                height: 300,
              ),
            ),
          ),
        if (_currentImageBytes != null)
          SizedBox(height: AppLayout.defaultPadding),
        if (_currentImageBytes != null)
          Row(
            children: [
              Spacer(),
              GtButton(
                style: GtButtonStyle.outlined,
                onPressed:
                    _isCompressing || widget.onResume == null
                        ? null
                        : () => _getPicture(context),
                child: const Text('Retake'),
              ),
              SizedBox(width: 10),
              GtButton(
                style: GtButtonStyle.elevated,
                onPressed: widget.onResume == null ? null : _submit,
                child: const Text('Submit'),
              ),
              Spacer(),
            ],
          ),
      ],
    );
  }

  void _skipPhoto() {
    debugPrint('skipping');
  }

  void _getPicture(BuildContext context) async {
    final file = await PlatformUtil.getPicture(context);
    if (file == null) return;
    _currentImageBytes = await file.readAsBytes();
    setState(() {});
  }

  void _submit() async {
    assert(widget.onResume != null);
    assert(_currentImageBytes != null);

    // shrink the image if it's too large for Genkit
    setState(() => _isCompressing = true);

    // give the web a chance to show the disabled buttons
    Future.delayed(const Duration(microseconds: kIsWeb ? 250 : 0), () async {
      final bytes = (await _resizeImageIfNeeded(_currentImageBytes!))!;

      widget.onResume!(
        ref: widget.message.toolRequest!.ref,
        name: widget.message.toolRequest!.name,
        output: 'data:image/jpeg;base64,${base64Encode(bytes)}',
      );
      setState(() => _isCompressing = false);
    });
  }

  Future<Uint8List?> _resizeImageIfNeeded(Uint8List bytes) async {
    debugPrint('Starting image resize operation with ${bytes.length} bytes');

    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) {
      debugPrint('Failed to decode image, returning null');
      return null;
    }

    debugPrint(
      'Original image dimensions: ${originalImage.width}x${originalImage.height}',
    );

    // Early bailout if image is already small enough
    if (originalImage.width <= 400 && originalImage.height <= 400) {
      debugPrint('Image already small enough, skipping resize');
      return bytes;
    }

    // resize image to max dimension of 400px while maintaining aspect ratio
    final resized = img.copyResize(
      originalImage,
      width: originalImage.width > originalImage.height ? 350 : null,
      height: originalImage.height >= originalImage.width ? 350 : null,
    );

    debugPrint('Resized image dimensions: ${resized.width}x${resized.height}');

    // encode as JPG with 85% quality and create data URL
    final jpgBytes = img.encodeJpg(resized, quality: 85);
    debugPrint('Compressed image size: ${jpgBytes.length} bytes');

    return jpgBytes;
  }
}
