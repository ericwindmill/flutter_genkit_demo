import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../greenthumb/service.dart';
import '../widgets/gt_button.dart';
import 'view_model.dart';

class InterruptChoicePicker extends StatelessWidget {
  InterruptChoicePicker({
    required InterruptMessage message,
    required this.onResume,
    super.key,
  }) : question = message.text,
       choices = message.toolRequest!.input.choices,
       selectedValue = message.toolResponse?.output,
       toolRef = message.toolRequest!.ref,
       toolName = message.toolRequest!.name;

  final String question;
  final Iterable<String> choices;
  final String? selectedValue;
  final String? toolRef;
  final String toolName;
  final ToolResumeCallback? onResume;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              question,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  for (final choice in choices)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                        width: 300,
                        child: GtButton(
                          style:
                              choice == selectedValue
                                  ? GtButtonStyle.elevated
                                  : GtButtonStyle.outlined,
                          onPressed:
                              selectedValue == null && onResume != null
                                  ? () => onResume!(
                                    ref: toolRef,
                                    name: toolName,
                                    output: choice,
                                  )
                                  : null,
                          child: Text(choice, textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
