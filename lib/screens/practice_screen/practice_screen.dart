import 'package:flutter/material.dart';
import 'package:QuickMath_Kids/question_logic/question_generator.dart';
import 'package:QuickMath_Kids/screens/practice_screen/modals/quit_modal.dart';
import 'package:QuickMath_Kids/screens/practice_screen/modals/pause_modal.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/timer_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/tts_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/operation_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/hint_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/confetti_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/answer_option_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/ui/hint_card.dart';
import 'package:QuickMath_Kids/screens/practice_screen/ui/timer_card.dart';
import 'package:QuickMath_Kids/screens/practice_screen/ui/answer_button.dart';
import 'package:QuickMath_Kids/screens/practice_screen/ui/pause_button.dart';
import 'package:QuickMath_Kids/wrong_answer_storing/wrong_answer_service.dart';

class PracticeScreen extends StatefulWidget {
  final Function(List<String>, List<bool>, int) switchToResultScreen;
  final VoidCallback switchToStartScreen;
  final Function(String) triggerTTS;
  final Operation selectedOperation;
  final String selectedRange;

  const PracticeScreen(this.switchToResultScreen, this.switchToStartScreen,
      this.triggerTTS, this.selectedOperation, this.selectedRange,
      {super.key});

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  List<int> numbers = [0, 0, 0];
  List<int> answerOptions = [];
  List<String> answeredQuestions = [];
  List<bool> answeredCorrectly = [];
  List<Map<String, dynamic>> _wrongQuestions = [];

  int correctAnswer = 0;

  String resultText = '';
  String currentHintMessage = '';

  bool hasListenedToQuestion = false;
  bool _isHintExpanded = false;
  bool isFromWrongQuestions = false; // Track if question is from wrong answers
  final HintManager hintManager = HintManager();
  final QuizTimer _quizTimer = QuizTimer();

  late ConfettiManager confettiManager;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late TTSHelper _ttsHelper;

  @override
  void initState() {
    super.initState();
    regenerateNumbers();
    _updateHintMessage();
    _loadWrongQuestions();
    confettiManager = ConfettiManager();
    _ttsHelper = TTSHelper(widget.triggerTTS);
    _quizTimer.startTimer((secondsPassed) {
      setState(() {
        // Timer callback
      });
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _quizTimer.stopTimer();
    confettiManager.dispose();
    super.dispose();
  }

  Future<void> _loadWrongQuestions() async {
    List<Map<String, dynamic>> allWrongQuestions =
        await WrongQuestionsService.getWrongQuestions();

    // Filter wrong questions by selected operation
    _wrongQuestions = allWrongQuestions.where((question) {
      String category = question['category'] ?? '';
      return category
          .startsWith(widget.selectedOperation.toString().split('.').last);
    }).toList();

    if (_wrongQuestions.isNotEmpty) {
      _loadNextWrongQuestion();
    } else {
      regenerateNumbers();
    }
  }

  void _loadNextWrongQuestion() {
    if (_wrongQuestions.isNotEmpty) {
      var question = _wrongQuestions.removeAt(0);

      setState(() {
        numbers = _parseQuestion(question['question']);
        correctAnswer = question['correctAnswer'];
        answerOptions = generateAnswerOptions(correctAnswer);
        isFromWrongQuestions = true; // Mark as from wrong questions
      });
    } else {
      regenerateNumbers();
    }
  }

  void _updateHintMessage() {
    setState(() {
      currentHintMessage = hintManager.getRandomHintMessage();
    });
  }

  void stopTimer() {
    _quizTimer.stopTimer();
  }

  void pauseTimer() {
    _quizTimer.pauseTimer();
  }

  void resumeTimer() {
    _quizTimer.resumeTimer();
  }

  String formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void regenerateNumbers() {
    setState(() {
      numbers = QuestionGenerator().generateTwoRandomNumbers(
          widget.selectedOperation, widget.selectedRange);
      correctAnswer = numbers.length > 2 ? numbers[2] : numbers[1];
      answerOptions = generateAnswerOptions(correctAnswer);
      isFromWrongQuestions = false; // Freshly generated question
    });
  }

  void checkAnswer(int selectedAnswer) {
  bool isCorrect = selectedAnswer == correctAnswer;

  setState(() {
    // Store question in format: "X + Y = UserAnswer (Correct/Wrong, Correct Answer = Z)"
    String questionText =
        '${numbers[0]} ${_getOperatorSymbol(widget.selectedOperation)} ${numbers[1]} = $selectedAnswer '
        '(${isCorrect ? "Correct" : "Wrong, The correct answer is $correctAnswer"})';

    answeredQuestions.add(questionText);
    answeredCorrectly.add(isCorrect);

    if (!isCorrect) {
      WrongQuestionsService.saveWrongQuestion(
        question: _formatQuestionText(),
        userAnswer: selectedAnswer,
        correctAnswer: correctAnswer,
        category:
            '${widget.selectedOperation.toString().split('.').last} - ${widget.selectedRange}',
      );
    } else {
      confettiManager.correctConfettiController.play();
      if (isFromWrongQuestions) {
        WrongQuestionsService.removeWrongQuestion(0);
      }
    }

    if (_wrongQuestions.isNotEmpty) {
      _loadNextWrongQuestion();
    } else {
      regenerateNumbers();
    }
  });

  _triggerTTSSpeech();
}


  List<int> _parseQuestion(String questionText) {
    RegExp regExp = RegExp(r'\d+');
    return regExp
        .allMatches(questionText)
        .map((m) => int.parse(m[0]!))
        .toList();
  }

  String _formatQuestionText() {
    return '${numbers[0]} ${_getOperatorSymbol(widget.selectedOperation)} ${numbers[1]}';
  }

  String _getOperatorSymbol(Operation operation) {
    return OperatorHelper.getOperatorSymbol(operation);
  }

  void _triggerTTSSpeech() {
    _ttsHelper.playSpeech(widget.selectedOperation, numbers);
    setState(() {
      hasListenedToQuestion = true;
    });
  }

  void endQuiz() {
    stopTimer();
    widget.switchToResultScreen(
        answeredQuestions, answeredCorrectly, _quizTimer.secondsPassed);
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QuitDialog(
          onQuit: () {
            widget.switchToStartScreen();
          },
        );
      },
    );
  }

  void _showPauseDialog() {
    pauseTimer();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PauseDialog(onResume: resumeTimer);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme

    return Scaffold(
      backgroundColor:
          theme.colorScheme.background, // Use background color based on theme
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme
            .backgroundColor, // Use appBar background color based on theme
        title: Text(
          'Practice',
          style: TextStyle(
            color: theme.appBarTheme.titleTextStyle
                ?.color, // Use title color based on theme
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _showQuitDialog,
              icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white),
              label: const Text('Quit', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: endQuiz,
              icon: const Icon(Icons.assessment, color: Colors.white),
              label:
                  const Text('Results', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Stack(
          children: [
            confettiManager.buildCorrectConfetti(),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Timer Card
                      buildTimerCard(
                          _quizTimer.formatTime(_quizTimer.secondsPassed),
                          context),
                      const SizedBox(height: 20),
                      // Hint Card
                      buildHintCard(currentHintMessage, _isHintExpanded, () {
                        setState(() {
                          _isHintExpanded = !_isHintExpanded;
                        });
                      }, context),
                      const SizedBox(height: 20),
                      // Voice Button
                      ElevatedButton(
                        onPressed: _triggerTTSSpeech,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(24),
                          elevation: 8,
                        ),
                        child: const Icon(
                          Icons.record_voice_over,
                          size: 100,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Answer Options
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme
                              .surface, // Use surface color based on theme
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildAnswerButton(answerOptions[0],
                                    () => checkAnswer(answerOptions[0])),
                                const SizedBox(width: 16),
                                buildAnswerButton(answerOptions[1],
                                    () => checkAnswer(answerOptions[1])),
                              ],
                            ),
                            const SizedBox(height: 16),
                            buildAnswerButton(answerOptions[2],
                                () => checkAnswer(answerOptions[2])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              child: buildPauseButton(_showPauseDialog, context),
              bottom: 24,
              right: 24,
            ),
          ],
        ),
      ),
    );
  }
}
