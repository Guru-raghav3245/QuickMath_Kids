import 'package:flutter/material.dart';


Widget buildTimerCard(String time, BuildContext context) {
  final theme = Theme.of(context);
  final screenWidth = MediaQuery.of(context).size.width;
  final scale = screenWidth / 360;
  final adjustedScale = screenWidth > 600 ? scale.clamp(0.8, 1.2) : scale;
  final isTablet = screenWidth > 600;

  double paddingHorizontal = isTablet ? screenWidth * 0.06 : 16 * adjustedScale;
  double paddingVertical = isTablet ? screenWidth * 0.03 : 8 * adjustedScale;
  double fontSizeTitle = isTablet ? screenWidth * 0.045 : 16 * adjustedScale;
  double fontSizeTime = isTablet ? screenWidth * 0.09 : 24 * adjustedScale;

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12 * adjustedScale),
    ),
    color: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
    child: Padding(
      padding: EdgeInsets.symmetric(
        vertical: paddingVertical,
        horizontal: paddingHorizontal,
      ),
      child: Column(
        children: [
          Text(
            'Time',
            style: TextStyle(
              fontSize: fontSizeTitle,
              color: theme.brightness == Brightness.dark ? Colors.black : Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4 * adjustedScale),
          Text(
            time,
            style: TextStyle(
              fontSize: fontSizeTime,
              color: theme.brightness == Brightness.dark ? Colors.blue[300] : Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}