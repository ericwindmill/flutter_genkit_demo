import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/main.dart';

import '../greenthumb/service.dart';
import '../styles.dart';
import '../view_models/view_model.dart';

class UserPromptPicker extends StatelessWidget {
  UserPromptPicker({this.onRequest, required Message message, super.key})
    : assert(message is UserRequest),
      selectedAction = GardeningAction.fromPrompt(message.text);

  final GardeningAction? selectedAction;
  final ToolRequestCallback? onRequest;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var padding = 10.0;
    if (width >= breakpoint) {
      padding = width / 6;
    }

    return Padding(
      padding: EdgeInsets.only(left: max(padding - 64, 0), right: padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 0, top: 20),
            child: Text(
              'Welcome to',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 0),
            child: Text(
              'GreenThumb!',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 400,
              child: Text(
                'GreenThumb provides gardening advice based on your unique circumstance.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: AppLayout.largePadding),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.largePadding,
            ),
            child: Center(
              child: Wrap(
                spacing: AppLayout.extraLargePadding,
                runSpacing: AppLayout.defaultPadding,
                alignment: WrapAlignment.center,
                children: [
                  for (final action in GardeningAction.values)
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap:
                              onRequest != null
                                  ? () => onRequest!(action.prompt)
                                  : null,
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                action.icon,
                                size: 28,
                                color: AppColors.primaryDark,
                              ),
                              SizedBox(height: AppLayout.defaultPadding),
                              Text(
                                action.buttonName,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.actionButton,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

enum GardeningAction {
  expandGarden(
    buttonName: 'Get started',
    icon: Icons.local_florist_outlined,
    prompt: 'I\'d like to expand my garden.',
  );

  const GardeningAction({
    required this.buttonName,
    required this.prompt,
    required this.icon,
  });

  final String buttonName;
  final String prompt;
  final IconData icon;

  static GardeningAction? fromPrompt(String? prompt) =>
      values.firstWhereOrNull((v) => v.prompt == prompt);
}
