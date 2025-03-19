import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;

import '../greenthumb/service.dart';
import '../platform_util.dart';
import '../widgets/gt_button.dart';
import 'view_model.dart';

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
  Widget build(BuildContext context) => Expanded(
    child: Stack(
      children: [
        // Keep the Take picture button centered vertically
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GtButton(
              style:
                  _currentImageBytes == null
                      ? GtButtonStyle.elevated
                      : GtButtonStyle.outlined,
              onPressed:
                  _isCompressing || widget.onResume == null
                      ? null
                      : () => _getPicture(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt),
                  const SizedBox(width: 8),
                  const Text('Take picture'),
                ],
              ),
            ),
          ),
        ),
        // Position text block centered between app bar and button
        Align(
          alignment: const Alignment(0, -0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: MarkdownBody(
              data: widget.message.text,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: WrapAlignment.center,
              ),
            ),
          ),
        ),
        // Position image and submit button at bottom
        if (_currentImageBytes != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32, left: 32, right: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 200,
                    child: Image.memory(
                      _currentImageBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GtButton(
                    style: GtButtonStyle.elevated,
                    onPressed:
                        _isCompressing || widget.onResume == null
                            ? null
                            : _submit,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

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
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) return null;

    // resize image to max dimension of 400px while maintaining aspect ratio
    final resized = img.copyResize(
      originalImage,
      width: originalImage.width > originalImage.height ? 400 : null,
      height: originalImage.height >= originalImage.width ? 400 : null,
    );

    // encode as JPG with 85% quality and create data URL
    return img.encodeJpg(resized, quality: 85);
  }
}
