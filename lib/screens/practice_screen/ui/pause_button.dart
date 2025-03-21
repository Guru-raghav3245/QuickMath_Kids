import 'package:flutter/material.dart';

Widget buildPauseButton(VoidCallback onPressed, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final scale = screenWidth / 360; // Same scaling logic as AppTheme
    final adjustedScale = isTablet ? scale.clamp(0.8, 1.2) : scale;

    final size = isTablet ? screenWidth * 0.12 : 48 * adjustedScale;

    return Container(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          elevation: 4,
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.all(size * 0.2),
        ),
        child: Icon(
          Icons.pause,
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }