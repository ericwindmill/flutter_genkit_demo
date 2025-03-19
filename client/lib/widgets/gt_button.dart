import 'package:flutter/material.dart';

enum GtButtonStyle { outlined, elevated }

class GtButton extends StatelessWidget {
  const GtButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style = GtButtonStyle.outlined,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final GtButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final buttonStyle =
        style == GtButtonStyle.outlined
            ? OutlinedButton.styleFrom(
              disabledForegroundColor: Colors.grey,
              foregroundColor: const Color(0xff1B5E20),
              side: const BorderSide(color: Color(0xff1B5E20)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            )
            : ElevatedButton.styleFrom(
              disabledBackgroundColor: Colors.grey,
              backgroundColor: const Color(0xff2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            );

    return style == GtButtonStyle.outlined
        ? OutlinedButton(onPressed: onPressed, style: buttonStyle, child: child)
        : ElevatedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child,
        );
  }
}
