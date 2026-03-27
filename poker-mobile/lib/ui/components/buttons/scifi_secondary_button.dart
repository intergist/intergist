// Poker Sharp — SciFiSecondaryButton Widget

import 'package:flutter/material.dart';

import '../../tokens/radius_tokens.dart';
import '../../tokens/spacing_tokens.dart';

class SciFiSecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SciFiSecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(AppRadius.md),
        ),
        side: BorderSide(color: colorScheme.outline),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpace.sm),
                ],
                Text(label),
              ],
            ),
    );
  }
}
