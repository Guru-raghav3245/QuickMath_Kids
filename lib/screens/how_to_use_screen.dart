import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'App Guide',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          backgroundColor: theme.colorScheme.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          bottom: TabBar(
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.6),
            indicatorColor: theme.colorScheme.secondary,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "How to Use"),
              Tab(text: "Content Overview"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUsageGuide(context, isTablet, theme),
            _buildContentOverview(context, isTablet, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageGuide(
      BuildContext context, bool isTablet, ThemeData theme) {
    return Container(
      color: theme.colorScheme.background,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 800 : 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildIntro(context),
                const SizedBox(height: 24),
                _buildStep(
                  context,
                  "1. Select Your Math Operation",
                  "From the home screen, pick an operation to practice: Addition, Subtraction, Multiplication, or Division.",
                  Icons.calculate,
                ),
                _buildStep(
                  context,
                  "2. Choose a Difficulty Range",
                  "Select a range that matches your skill level, like 'Up to +5' or 'Up to +10'.",
                  Icons.tune,
                ),
                _buildStep(
                  context,
                  "3. Set a Time Limit (Optional)",
                  "Tap the time limit field to open the scroll wheel. Choose a duration (1-60 minutes) or select 'No time limit'.",
                  Icons.timer,
                ),
                _buildStep(
                  context,
                  "4. Begin Your Practice",
                  "Hit 'Start Oral Practice' to launch the quiz. Questions will be spoken aloud.",
                  Icons.play_circle_filled,
                ),
                _buildStep(
                  context,
                  "5. Answer Questions",
                  "Listen to each question (tap the voice button to replay), then pick the correct answer.",
                  Icons.volume_up,
                ),
                _buildStep(
                  context,
                  "6. Manage Your Session",
                  "Pause to take a break or quit to return to the start screen.",
                  Icons.pause_circle_outline,
                ),
                _buildStep(
                  context,
                  "7. Review Wrong Answers",
                  "Check 'Wrong Answers History' in the drawer to practice missed questions.",
                  Icons.history,
                ),
                _buildStep(
                  context,
                  "8. See Your Results",
                  "View your time, total questions, and correct answers. Wrong answers are saved.",
                  Icons.bar_chart,
                ),
                _buildStep(
                  context,
                  "9. Share Your Progress",
                  "Tap 'Share Report' to create and send a PDF of your quiz performance.",
                  Icons.share,
                ),
                const SizedBox(height: 24),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentOverview(
      BuildContext context, bool isTablet, ThemeData theme) {
    // Data detailing the logic from QuestionGenerator
    final List<Map<String, dynamic>> operatorData = [
      {
        'name': 'Addition',
        'icon': Icons.add_circle_outline,
        'levels': [
          {
            'name': 'Beginner',
            'color': Colors.green,
            'desc': 'Logic: Operands are within the range.',
            'ranges':
                '• Ranges like "1-5" mean both numbers are between 1 and 5.\n• Specifics like "+1" add exactly 1 to a number.'
          },
          {
            'name': 'Intermediate',
            'color': Colors.orange,
            'desc': 'Logic: The Final Sum is controlled.',
            'ranges':
                '• Ranges like "10-20" mean the SUM of the two numbers will fall between 10 and 20.'
          },
          {
            'name': 'Advanced',
            'color': Colors.red,
            'desc': 'Logic: The Final Sum is controlled.',
            'ranges':
                '• Ranges like "50-100" mean the SUM of the two numbers will fall between 50 and 100.'
          },
        ]
      },
      {
        'name': 'Subtraction',
        'icon': Icons.remove_circle_outline,
        'levels': [
          {
            'name': 'Beginner',
            'color': Colors.green,
            'desc': 'Logic: Subtraction from small numbers.',
            'ranges':
                '• Ranges like "1-10" mean the starting number is between 1-10.\n• Specifics like "-1" subtract exactly 1.'
          },
          {
            'name': 'Intermediate',
            'color': Colors.orange,
            'desc': 'Logic: The Answer stays within range.',
            'ranges':
                '• Ranges like "20-30" mean the starting number is 20-30, and the Answer is kept roughly within that tier.'
          },
          {
            'name': 'Advanced',
            'color': Colors.red,
            'desc': 'Logic: The Answer stays within range.',
            'ranges':
                '• Ranges like "50-100" mean the starting number is 50-100, and the Answer is kept roughly within that tier.'
          },
        ]
      },
      {
        'name': 'Multiplication',
        'icon': Icons.cancel_outlined,
        'levels': [
          {
            'name': 'Beginner',
            'color': Colors.green,
            'desc': 'Logic: Multiplier is fixed or small.',
            'ranges':
                '• "x2" means (1-10) multiplied by 2.\n• Mixed includes x2 through x5.'
          },
          {
            'name': 'Intermediate',
            'color': Colors.orange,
            'desc': 'Logic: Multiplier is mid-range.',
            'ranges':
                '• "x6" means (1-10) multiplied by 6.\n• Mixed includes x6 through x9.'
          },
          {
            'name': 'Advanced',
            'color': Colors.red,
            'desc': 'Logic: Multiplier is large.',
            'ranges':
                '• "x10" means (1-10) multiplied by 10.\n• Mixed includes up to x12.'
          },
        ]
      },
      {
        'name': 'Division',
        'icon': Icons.percent,
        'levels': [
          {
            'name': 'Beginner',
            'color': Colors.green,
            'desc': 'Logic: Divisor is fixed or small.',
            'ranges':
                '• "÷2" means a number is divided by 2 (Quotient 1-10).\n• Mixed includes ÷2 through ÷5.'
          },
          {
            'name': 'Intermediate',
            'color': Colors.orange,
            'desc': 'Logic: Divisor is mid-range.',
            'ranges':
                '• "÷6" means a number is divided by 6 (Quotient 1-10).\n• Mixed includes ÷6 through ÷9.'
          },
          {
            'name': 'Advanced',
            'color': Colors.red,
            'desc': 'Logic: Large divisors.',
            'ranges': '• "Mixed" includes divisors from 2 to 10.'
          },
        ]
      },
      {
        'name': 'LCM (Least Common Multiple)',
        'icon': Icons.filter_1,
        'levels': [
          {
            'name': 'All Levels',
            'color': Colors.blue,
            'desc': 'Logic: Range applies to INPUT numbers.',
            'ranges':
                '• "Up to 10" means finding the LCM of two numbers that are each ≤ 10.\n• NOTE: The Answer (LCM) can be larger than 10 (e.g., LCM of 9 & 10 is 90).'
          },
        ]
      },
      {
        'name': 'GCF (Greatest Common Factor)',
        'icon': Icons.filter_center_focus,
        'levels': [
          {
            'name': 'All Levels',
            'color': Colors.blue,
            'desc': 'Logic: Range applies to INPUT numbers.',
            'ranges':
                '• "Up to 10" means finding the GCF of two numbers that are each ≤ 10.\n• The Answer will always be ≤ the input numbers.'
          },
        ]
      },
    ];

    return Container(
      color: theme.colorScheme.background,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 800 : 600),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            itemCount: operatorData.length,
            itemBuilder: (context, index) {
              final op = operatorData[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Icon(op['icon'], color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    op['name'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: (op['levels'] as List).map<Widget>((level) {
                    return Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (level['color'] as Color).withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: level['color'],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                level['name'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: level['color'],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level['desc'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  (level['color'] as Color).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              level['ranges'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: theme.colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.school, color: theme.colorScheme.primary, size: 36),
        const SizedBox(width: 12),
        Text(
          "Get Started!",
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildIntro(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "QuickMath Kids makes math fun with audio-based questions. Follow these steps to start learning!",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
      BuildContext context, String title, String description, IconData icon) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "Enjoy math anytime, anywhere, offline!",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
