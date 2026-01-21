import 'package:flutter/material.dart';

class ResultRowWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const ResultRowWidget({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align top if text wraps
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
