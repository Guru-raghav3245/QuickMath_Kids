import 'package:quickmath_kids/question_logic/enum_values.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/quiz_history_service.dart';
import 'package:quickmath_kids/screens/result_screen/result_screen.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  _QuizHistoryScreenState createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  List<Map<String, dynamic>> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() {
      _isLoading = true;
    });
    final quizzes = await QuizHistoryService.getQuizzes();
    setState(() {
      _quizzes = quizzes..sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      _isLoading = false;
    });
  }

  Future<void> _removeQuiz(String title) async {
    final quizToRemove = _quizzes.firstWhere((q) => q['title'] == title);
    setState(() {
      _quizzes.removeWhere((q) => q['title'] == title);
    });
    try {
      await QuizHistoryService.removeQuiz(title);
    } catch (e) {
      setState(() {
        _quizzes.add(quizToRemove);
        _quizzes.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove quiz: $e',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _clearAllQuizzes() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Quiz History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all quiz history? This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Clear',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await QuizHistoryService.clearQuizzes();
        setState(() {
          _quizzes.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quiz history cleared',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to clear history: $e',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _renameQuiz(String oldTitle) async {
    final controller = TextEditingController(text: oldTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rename Quiz',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'New Title',
            hintText: 'Enter a new title',
            labelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            hintStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != oldTitle) {
      try {
        await QuizHistoryService.renameQuiz(oldTitle, newTitle);
        setState(() {
          final quiz = _quizzes.firstWhere((q) => q['title'] == oldTitle);
          quiz['title'] = newTitle;
          _quizzes.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quiz renamed successfully',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to rename quiz: $e',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quiz History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (!_isLoading && _quizzes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all quizzes',
              onPressed: _clearAllQuizzes,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizzes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'No quiz history yet!',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete a quiz to save it here',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _quizzes.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final quiz = _quizzes[index];
                    return Dismissible(
                      key: ValueKey(quiz['title']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) => _removeQuiz(quiz['title']),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          title: Text(
                            quiz['title'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _renameQuiz(quiz['title']),
                            tooltip: 'Rename quiz',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultScreen.fromHistory(
                                  title: quiz['title'],
                                  answeredQuestions: List<String>.from(quiz['questions']),
                                  answeredCorrectly: List<bool>.from(quiz['correctness']),
                                  totalTime: quiz['totalTime'],
                                  operation: Operation.values.firstWhere(
                                    (op) => op.toString().split('.').last == quiz['operation'],
                                    orElse: () => Operation.additionBeginner,
                                  ),
                                  range: quiz['range'],
                                  timeLimit: quiz['timeLimit'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}