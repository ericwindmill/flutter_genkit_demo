import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import '../greenthumb/service.dart';
import '../widgets/gt_button.dart';
import 'view_model.dart';

class InterruptRangeValuePicker extends StatefulWidget {
  InterruptRangeValuePicker({
    required InterruptMessage message,
    required this.onResume,
    super.key,
  }) : assert(message.toolRequest!.input.min != null),
       assert(message.toolRequest!.input.max != null),
       question = message.text,
       min = message.toolRequest!.input.min!,
       max = message.toolRequest!.input.max!,
       selectedValue = int.tryParse(message.toolResponse?.output ?? ''),
       toolRef = message.toolRequest!.ref,
       toolName = message.toolRequest!.name;

  final String question;
  final int min;
  final int max;
  final int? selectedValue;
  final String? toolRef;
  final String toolName;
  final ToolResumeCallback? onResume;

  @override
  State<InterruptRangeValuePicker> createState() =>
      _InterruptRangeValuePickerState();
}

class _InterruptRangeValuePickerState extends State<InterruptRangeValuePicker> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();

    _currentValue =
        widget.selectedValue ?? ((widget.min + widget.max) / 2).round();
  }

  @override
  Widget build(BuildContext context) => Expanded(
    child: Stack(
      children: [
        // Center the submit button vertically
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: GtButton(
              style: GtButtonStyle.elevated,
              onPressed:
                  widget.onResume == null
                      ? null
                      : () {
                        widget.onResume!(
                          ref: widget.toolRef,
                          name: widget.toolName,
                          output: _currentValue.toString(),
                        );
                      },
              child: const Text('Submit'),
            ),
          ),
        ),
        // Position question and range controls between app bar and button
        Align(
          alignment: const Alignment(0, -0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MarkdownBody(
                  data: widget.question,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: WrapAlignment.center,
                  ),
                ),
                const SizedBox(height: 32),
                Slider(
                  value: _currentValue.toDouble(),
                  min: widget.min.toDouble(),
                  max: widget.max.toDouble(),
                  divisions: min(widget.max - widget.min, 10),
                  label: _currentValue.toString(),
                  onChanged:
                      (value) => setState(() => _currentValue = value.round()),
                  activeColor: Colors.green,
                ),
                Text(
                  _currentValue.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
