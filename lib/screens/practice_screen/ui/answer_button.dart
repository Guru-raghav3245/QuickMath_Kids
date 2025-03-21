import 'package:flutter/material.dart';

Widget buildAnswerButton(int answer, VoidCallback onPressed) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final screenWidth = MediaQuery.of(context).size.width;
      final scale = screenWidth / 360;
      final adjustedScale = screenWidth > 600 ? scale.clamp(0.8, 1.2) : scale;
      final isTablet = screenWidth > 600;

      final buttonWidth = isTablet ? screenWidth * 0.5 : 100 * adjustedScale;
      final buttonHeight = isTablet ? screenWidth * 0.15 : 50 * adjustedScale;
      final fontSize = isTablet ? screenWidth * 0.05 : 18 * adjustedScale;

      return SizedBox(
        width: buttonWidth.clamp(80, 170),
        height: buttonHeight.clamp(40, 60),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12 * adjustedScale),
            ),
            elevation: 4,
          ),
          child: Text(
            answer.toString(),
            style: TextStyle(
              fontSize: fontSize.clamp(16, 20),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    },
  );
}