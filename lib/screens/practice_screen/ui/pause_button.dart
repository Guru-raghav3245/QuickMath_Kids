import 'package:flutter/material.dart';

Widget buildPauseButton(VoidCallback onPressed, BuildContext context) {
  final theme = Theme.of(context);
  final screenWidth = MediaQuery.of(context).size.width;
  final scale = screenWidth / 360;
  final adjustedScale = screenWidth > 600 ? scale.clamp(0.8, 1.2) : scale;
  final isTablet = screenWidth > 600;

  final size = isTablet ? screenWidth * 0.12 : 48 * adjustedScale;

  return SizedBox(
    width: size,
    height: size,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        elevation: 4,
        backgroundColor: theme.colorScheme.primary,
        padding: EdgeInsets.all(size * 0.2),
      ),
      child: Icon(
        Icons.pause,
        size: size * 0.6,
        color: theme.colorScheme.onPrimary,
      ),
    ),
  );
}