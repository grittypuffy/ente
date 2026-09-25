import 'package:ente_auth/theme/colors.dart';
import 'package:ente_auth/theme/ente_theme.dart';
import 'package:flutter/material.dart';

enum RoundedButtonType { primary, secondary, primaryInverse, secondaryInverse }

class RoundedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final RoundedButtonType type;

  const RoundedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.type = RoundedButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = getEnteTextTheme(context);
    final colorScheme = getEnteColorScheme(context);
    final isDarkTheme = !colorScheme.isLightTheme;

    final (backgroundColor, textColor) = switch (type) {
      RoundedButtonType.primary => (accentColor, Colors.white),
      RoundedButtonType.secondary => (
        isDarkTheme ? const Color(0x29A75CFF) : const Color(0x0AA75CFF),
        colorScheme.textBase,
      ),
      RoundedButtonType.primaryInverse => (Colors.white, accentColor),
      RoundedButtonType.secondaryInverse => (
        Colors.white.withValues(alpha: 0.2),
        Colors.white,
      ),
    };

    return Semantics(
      container: true,
      button: true,
      enabled: onPressed != null,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: ExcludeSemantics(
          child: Container(
            width: width,
            // [Accessibility] Grow with text instead of clipping the label.
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: ShapeDecoration(
              color: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Center(
              // [Accessibility] Center wrapped label lines.
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: textTheme.small.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
