import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // Function to launch Gmail app specifically
  Future<void> _launchGmail() async {
    final Uri gmailUri = Uri(
      scheme: 'googlegmail',
      path: '/mail/compose',
      queryParameters: {
        'to': 'master.guru.raghav@gmail.com',
        'subject': 'Support Request',
      },
    );

    // Fallback to regular mailto if Gmail app isn't available
    final Uri fallbackUri = Uri(
      scheme: 'mailto',
      path: 'master.guru.raghav@gmail.com',
      queryParameters: {
        'subject': 'Support Request',
      },
    );

    try {
      if (await canLaunchUrl(gmailUri)) {
        await launchUrl(gmailUri);
      } else {
        // Fallback to default email client if Gmail app isn't installed
        await launchUrl(fallbackUri);
      }
    } catch (e) {
      print('Error launching email: $e');
      // You could show a snackbar here to inform the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Working Hours Section
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Working Hours',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Monday - Saturday',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '12:30 PM - 4:30 PM',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Gmail Support Button
            ElevatedButton.icon(
              onPressed: _launchGmail,
              icon: const Icon(Icons.email),
              label: const Text('Contact via Gmail'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}