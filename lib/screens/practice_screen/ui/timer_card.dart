import 'package:flutter/material.dart';

Widget buildTimerCard(String time, BuildContext context) {
  final theme = Theme.of(context);
  final screenWidth = MediaQuery.of(context).size.width * 0.8;
  final screenHeight = MediaQuery.of(context).size.height * 0.8;

  // Scale padding and font sizes based on screen width
  double paddingHorizontal = screenWidth * 0.06; // 6% of screen width
  double paddingVertical = screenHeight * 0.02;  // 2% of screen height
  double fontSizeTitle = screenWidth * 0.045;    // ~18 on a 400px wide screen
  double fontSizeTime = screenWidth * 0.09;      // ~36 on a 400px wide screen

  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(screenWidth * 0.04), // Scales radius
    ),
    color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
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
              color: theme.brightness == Brightness.dark
                  ? Colors.black
                  : Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenHeight * 0.01), // Scales spacing
          Text(
            time,
            style: TextStyle(
              fontSize: fontSizeTime,
              color: theme.brightness == Brightness.dark
                  ? Colors.blue[300]
                  : Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}