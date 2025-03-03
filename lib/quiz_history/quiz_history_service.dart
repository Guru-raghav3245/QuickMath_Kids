// lib/services/quiz_history_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:QuickMath_Kids/question_logic/question_generator.dart';

class QuizHistoryService {
  static const String _key = 'quiz_history';

  static Future<void> saveQuiz({
    required String title,
    required String timestamp,
    required Operation operation,
    required String range,
    required int? timeLimit,
    required int totalTime,
    required List<String> answeredQuestions,
    required List<bool> answeredCorrectly,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existingQuizzes = prefs.getStringList(_key) ?? [];

    Map<String, dynamic> quizData = {
      'title': title,
      'timestamp': timestamp,
      'operation': operation.toString().split('.').last,
      'range': range,
      'timeLimit': timeLimit,
      'totalTime': totalTime,
      'questions': answeredQuestions,
      'correctness': answeredCorrectly,
      'correctCount': answeredCorrectly.where((c) => c).length,
      'totalQuestions': answeredQuestions.length,
    };

    existingQuizzes.add(jsonEncode(quizData));
    await prefs.setStringList(_key, existingQuizzes);
  }

  static Future<List<Map<String, dynamic>>> getQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedQuizzes = prefs.getStringList(_key) ?? [];
    return storedQuizzes
        .map((string) => jsonDecode(string) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> removeQuiz(String title) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedQuizzes = prefs.getStringList(_key) ?? [];
    storedQuizzes.removeWhere((quiz) {
      final quizData = jsonDecode(quiz) as Map<String, dynamic>;
      return quizData['title'] == title;
    });
    await prefs.setStringList(_key, storedQuizzes);
  }

  static Future<void> clearQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<String> generateUniqueTitle(String baseTitle) async {
    final quizzes = await getQuizzes();
    String newTitle = baseTitle;
    int suffix = 2;

    while (quizzes.any((quiz) => quiz['title'] == newTitle)) {
      newTitle = '$baseTitle $suffix';
      suffix++;
    }
    return newTitle;
  }

  static Future<void> renameQuiz(String oldTitle, String newTitle) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedQuizzes = prefs.getStringList(_key) ?? [];
    final quizzes = storedQuizzes
        .map((string) => jsonDecode(string) as Map<String, dynamic>)
        .toList();

    // Check for duplicate titles
    String uniqueNewTitle = newTitle;
    int suffix = 2;
    while (quizzes.any((quiz) => quiz['title'] == uniqueNewTitle && quiz['title'] != oldTitle)) {
      uniqueNewTitle = '$newTitle $suffix';
      suffix++;
    }

    // Update the title
    for (int i = 0; i < storedQuizzes.length; i++) {
      Map<String, dynamic> quizData = jsonDecode(storedQuizzes[i]);
      if (quizData['title'] == oldTitle) {
        quizData['title'] = uniqueNewTitle;
        storedQuizzes[i] = jsonEncode(quizData);
        break;
      }
    }
    await prefs.setStringList(_key, storedQuizzes);
  }
}