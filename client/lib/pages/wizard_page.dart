import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/greenthumb/service.dart';
import 'package:flutter_fix_warehouse/views/interrupt_choice_picker.dart';
import 'package:flutter_fix_warehouse/views/interrupt_range_value_picker.dart';
import 'package:flutter_fix_warehouse/views/user_prompt_picker.dart';

import '../views/interrupt_image_picker.dart';
import '../views/model_response_view.dart';
import '../views/view_model.dart';

class WizardPage extends StatefulWidget {
  const WizardPage({super.key});

  @override
  State<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends State<WizardPage> {
  final _service = GreenthumbService();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _service,
    builder: (context, child) {
      final messages = _service.messages;
      final currentMessage = messages.isEmpty ? null : messages.last;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4CAF50),
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  children: [
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Icon(
                        Icons.eco_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Icon(Icons.star, color: Colors.white, size: 12),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                'GreenThumb',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body:
            currentMessage == null
                ? const Center(child: CircularProgressIndicator())
                : _buildStepView(currentMessage, true),
      );
    },
  );

  Widget _buildStepView(Message message, bool isCurrentStep) {
    // don't allow the user to form a request if we're already handling one
    final onRequest = isCurrentStep ? _onRequest : null;

    // don't allow the user to create a response if the tool already has one
    final hasToolResponse =
        message is InterruptMessage && message.toolResponse != null;
    final onResume = isCurrentStep && !hasToolResponse ? _onResume : null;

    return switch (message) {
      // gather initial user prompt
      UserRequest() => UserPromptPicker(message: message, onRequest: onRequest),

      // display final model response
      ModelResponse() => ModelResponseView(message: message),

      // Handle interrupt tools
      InterruptMessage() => switch (message.toolRequest!.name) {
        'choice' => InterruptChoicePicker(message: message, onResume: onResume),
        'image' => InterruptImagePicker(message: message, onResume: onResume),
        'range' => InterruptRangeValuePicker(
          message: message,
          onResume: onResume,
        ),
        _ => throw Exception('Unknown tool: ${message.toolRequest!.name}'),
      },
    };
  }

  void _onRequest(String prompt) => _service.request(prompt);

  void _onResume({String? ref, required String name, required String output}) =>
      _service.resume(ref: ref, name: name, output: output);
}
