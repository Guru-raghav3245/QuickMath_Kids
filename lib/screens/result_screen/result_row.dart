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
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 10),
        Text(
          '$label ',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[900],
          ),
        ),
      ],
    );
  }
}
