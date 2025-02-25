import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WrongQuestionsService {
  static const String _key = 'wrong_questions';

  /// Save a wrong question to storage
  static Future<void> saveWrongQuestion({
    required String question,
    required int userAnswer,
    required int correctAnswer,
    required String category,  // Added category parameter
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing wrong questions
    List<String> existingQuestions = prefs.getStringList(_key) ?? [];
    
    // Create new question entry
    Map<String, dynamic> questionData = {
      'question': question,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'category': category,  // Store the category
    };
    
    // Add new question to list
    existingQuestions.add(jsonEncode(questionData));
    
    // Save updated list
    await prefs.setStringList(_key, existingQuestions);
  }

  /// Get all wrong questions from storage
  static Future<List<Map<String, dynamic>>> getWrongQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedQuestions = prefs.getStringList(_key) ?? [];
    
    return storedQuestions
        .map((string) => jsonDecode(string) as Map<String, dynamic>)
        .toList();
  }

  // Method to remove a question
  static Future<void> removeWrongQuestion(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedQuestions = prefs.getStringList(_key) ?? [];

    if (index >= 0 && index < storedQuestions.length) {
      storedQuestions.removeAt(index);
      await prefs.setStringList(_key, storedQuestions);
    }
  }
}