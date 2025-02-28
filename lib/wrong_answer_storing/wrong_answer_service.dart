import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WrongQuestionsService {
  static const String _key = 'wrong_questions';

  static Future<void> saveWrongQuestion({
    required String question,
    required int userAnswer,
    required int correctAnswer,
    required String category,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> existingQuestions = prefs.getStringList(_key) ?? [];

    Map<String, dynamic> questionData = {
      'question': question,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'category': category,
      'sessionsRemaining': 3,
      'correctCount': 0,
      'timestamp': DateTime.now().toIso8601String(),
    };

    existingQuestions.add(jsonEncode(questionData));
    await prefs.setStringList(_key, existingQuestions);
  }

  static Future<List<Map<String, dynamic>>> getWrongQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedQuestions = prefs.getStringList(_key) ?? [];
    return storedQuestions.map((string) => jsonDecode(string) as Map<String, dynamic>).toList();
  }

  static Future<void> updateWrongQuestion(String question, {bool correct = false}) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedQuestions = prefs.getStringList(_key) ?? [];

    for (int i = 0; i < storedQuestions.length; i++) {
      Map<String, dynamic> questionData = jsonDecode(storedQuestions[i]);
      if (questionData['question'] == question) {
        if (correct) {
          int correctCount = (questionData['correctCount'] ?? 0) + 1;
          questionData['correctCount'] = correctCount;
          int sessionsRemaining = (questionData['sessionsRemaining'] ?? 3) - 1;
          questionData['sessionsRemaining'] = sessionsRemaining;
          if (sessionsRemaining <= 0) {
            storedQuestions.removeAt(i);
          } else {
            storedQuestions[i] = jsonEncode(questionData);
          }
        }
        break;
      }
    }
    await prefs.setStringList(_key, storedQuestions);
  }

  static Future<void> removeWrongQuestion(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedQuestions = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < storedQuestions.length) {
      storedQuestions.removeAt(index);
      await prefs.setStringList(_key, storedQuestions);
    }
  }

  static Future<void> clearWrongQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key); // Completely removes all stored wrong questions
  }
}