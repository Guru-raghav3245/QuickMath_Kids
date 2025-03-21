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
import 'package:QuickMath_Kids/screens/practice_screen/ui/timer_card.dart';
import 'package:QuickMath_Kids/screens/practice_screen/ui/answer_button.dart';
import 'package:QuickMath_Kids/wrong_answer_storing/wrong_answer_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:QuickMath_Kids/app_theme.dart';

class PracticeScreen extends StatefulWidget {
  final Function(List<String>, List<bool>, int, Operation, String, int?)
      switchToResultScreen;
  final VoidCallback switchToStartScreen;
  final Function(String) triggerTTS;
  final Operation selectedOperation;
  final String selectedRange;
  final int? sessionTimeLimit;
  final bool isDarkMode; // Added isDarkMode parameter

  const PracticeScreen(
    this.switchToResultScreen,
    this.switchToStartScreen,
    this.triggerTTS,
    this.selectedOperation,
    this.selectedRange,
    this.sessionTimeLimit, {
    required this.isDarkMode, // Required parameter
    super.key,
  });

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
  bool _usedWrongQuestionThisSession = false;
  bool _isInitialized = false;

  int correctAnswer = 0;
  String resultText = '';
  String currentHintMessage = '';
  bool hasListenedToQuestion = false;

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
    _initializeScreen();
    confettiManager = ConfettiManager();
    _ttsHelper = TTSHelper(widget.triggerTTS);
    _quizTimer.startTimer((secondsPassed) {
      setState(() {
        if (widget.sessionTimeLimit != null &&
            secondsPassed >= widget.sessionTimeLimit!) {
          endQuiz();
        }
      });
    });

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _quizTimer.stopTimer();
    confettiManager.dispose();
    super.dispose();
  }

  void stopTimer() => _quizTimer.stopTimer();
  void pauseTimer() => _quizTimer.pauseTimer();
  void resumeTimer() => _quizTimer.resumeTimer();

  Future<void> _initializeScreen() async {
    await _loadWrongQuestions();
    setState(() {
      _setInitialQuestion();
      _updateHintMessage();
      _isInitialized = true;
    });
  }

  Future<void> _loadWrongQuestions() async {
    List<Map<String, dynamic>> allWrongQuestions =
        await WrongQuestionsService.getWrongQuestions();
    setState(() {
      _wrongQuestions = allWrongQuestions.where((question) {
        String category = question['category'] ?? '';
        return category
            .startsWith(widget.selectedOperation.toString().split('.').last);
      }).toList();
    });
  }

  void _setInitialQuestion() {
    if (_wrongQuestions.isNotEmpty) {
      _useWrongQuestion();
    } else {
      regenerateNumbers();
    }
  }

  void _useWrongQuestion() {
    if (_wrongQuestions.isNotEmpty) {
      var question = _wrongQuestions[0];
      numbers = _parseQuestion(question['question']);
      correctAnswer = question['correctAnswer'];
      answerOptions = generateAnswerOptions(correctAnswer);
      _usedWrongQuestionThisSession = true;
    } else {
      regenerateNumbers();
    }
  }

  void _updateHintMessage() {
    currentHintMessage = hintManager.getRandomHintMessage();
  }

  String formatTime(int seconds) {
    if (widget.sessionTimeLimit == null) {
      final minutes = (seconds / 60).floor();
      final secs = seconds % 60;
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    } else {
      int remaining = widget.sessionTimeLimit! - seconds;
      if (remaining < 0) remaining = 0;
      final minutes = (remaining / 60).floor();
      final secs = remaining % 60;
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  void regenerateNumbers() {
    numbers = QuestionGenerator().generateTwoRandomNumbers(
        widget.selectedOperation, widget.selectedRange);
    correctAnswer = numbers.length > 2 ? numbers[2] : numbers[1];
    answerOptions = generateAnswerOptions(correctAnswer);
  }

  void checkAnswer(int selectedAnswer) {
    bool isCorrect = selectedAnswer == correctAnswer;

    setState(() {
      String questionText =
          '${numbers[0]} ${_getOperatorSymbol(widget.selectedOperation)} ${numbers[1]} = $selectedAnswer '
          '(${isCorrect ? "Correct" : "Wrong, The correct answer is $correctAnswer"})';
      answeredQuestions.add(questionText);
      answeredCorrectly.add(isCorrect);
      String currentQuestion = _formatQuestionText();

      if (!isCorrect) {
        // Check if the question already exists in wrong questions
        bool questionExists =
            _wrongQuestions.any((q) => q['question'] == currentQuestion);
        if (questionExists) {
          // Update the existing question by resetting correctCount to 0
          WrongQuestionsService.updateWrongQuestion(
            currentQuestion,
            correct: false, // Reset correctCount to 0 when wrong
          );
        } else {
          // Save as a new wrong question if it doesn’t exist
          WrongQuestionsService.saveWrongQuestion(
            question: currentQuestion,
            userAnswer: selectedAnswer,
            correctAnswer: correctAnswer,
            category:
                '${widget.selectedOperation.toString().split('.').last} - ${widget.selectedRange}',
          );
        }
        _loadWrongQuestions(); // Refresh the wrong questions list
      } else if (_usedWrongQuestionThisSession && _wrongQuestions.isNotEmpty) {
        // If answered correctly, update the existing wrong question
        WrongQuestionsService.updateWrongQuestion(currentQuestion,
            correct: true);
        _wrongQuestions.removeAt(0); // Remove from local list after updating
      }

      if (isCorrect) confettiManager.correctConfettiController.play();

      if (_wrongQuestions.isNotEmpty) {
        _useWrongQuestion();
      } else {
        regenerateNumbers();
      }
      _usedWrongQuestionThisSession = _wrongQuestions.isNotEmpty;
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
      answeredQuestions,
      answeredCorrectly,
      _quizTimer.secondsPassed,
      widget.selectedOperation,
      widget.selectedRange,
      widget.sessionTimeLimit,
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QuitDialog(onQuit: widget.switchToStartScreen);
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

  void _showHintDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
<<<<<<< Updated upstream
          title: const Text('Hint', style: TextStyle(color: Colors.white)),
          content: Text(currentHintMessage,
              style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900], // Dark background for dialog
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close', style: TextStyle(color: Colors.white)),
=======
          title: Text('Hint', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
          content: Text(currentHintMessage, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface)),
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: theme.colorScheme.primary)),
>>>>>>> Stashed changes
            ),
          ],
        );
      },
    );
  }

  Widget buildPauseButton(VoidCallback onPressed, BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width; // ~360 dp on 1080px, 3x density

    return Container(
      width:
          screenWidth * 0.12, // ~43 dp (~129 physical px on 3x), much smaller
      height: screenWidth * 0.12, // ~43 dp, keeps it circular
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary, // Thin border color
              width: 1.0, // Reduced thickness (default is thicker)
            ),
          ),
          elevation: 4, // Reduced from 8 for a flatter, less "thick" look
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.all(
              screenWidth * 0.02), // ~7 dp padding, tight but balanced
        ),
        child: Icon(
          Icons.pause_circle_filled, // Kept for clarity at smaller size
          size: screenWidth *
              0.08, // ~29 dp (~87 physical px), smaller but visible
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
<<<<<<< Updated upstream
        final theme = AppTheme.getTheme(ref, true, context); // Enable dark mode
=======
        final theme = AppTheme.getTheme(ref, widget.isDarkMode, context); // Use widget.isDarkMode
        final screenWidth = MediaQuery.of(context).size.width;
        final scale = screenWidth / 360;
        final adjustedScale = screenWidth > 600 ? scale.clamp(0.8, 1.2) : scale;
        final isTablet = screenWidth > 600;

>>>>>>> Stashed changes
        int displayTime = widget.sessionTimeLimit != null
            ? (widget.sessionTimeLimit! - _quizTimer.secondsPassed)
            : _quizTimer.secondsPassed;
        if (widget.sessionTimeLimit != null && displayTime < 0) displayTime = 0;

        final screenWidth = MediaQuery.of(context).size.width;

        if (!_isInitialized) {
          return Theme(
            data: theme,
            child: const Scaffold(
<<<<<<< Updated upstream
              body:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
=======
              body: Center(child: CircularProgressIndicator()),
>>>>>>> Stashed changes
            ),
          );
        }

        return Theme(
          data: theme,
          child: Scaffold(
            appBar: AppBar(
<<<<<<< Updated upstream
              title:
                  const Text('Practice', style: TextStyle(color: Colors.white)),
=======
              title: Text('Practice', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary)),
>>>>>>> Stashed changes
              backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: _showQuitDialog,
<<<<<<< Updated upstream
                    icon: const Icon(Icons.exit_to_app_rounded,
                        color: Colors.white),
                    label: const Text('Quit',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                    ),
=======
                    icon: Icon(Icons.exit_to_app_rounded, color: theme.colorScheme.onPrimary),
                    label: Text('Quit', style: TextStyle(color: theme.colorScheme.onPrimary)),
                    style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.error),
>>>>>>> Stashed changes
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: endQuiz,
<<<<<<< Updated upstream
                    icon: const Icon(Icons.assessment, color: Colors.white),
                    label: const Text('Results',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
=======
                    icon: Icon(Icons.assessment, color: theme.colorScheme.onPrimary),
                    label: Text('Results', style: TextStyle(color: theme.colorScheme.onPrimary)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
>>>>>>> Stashed changes
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Container(
<<<<<<< Updated upstream
                color: Colors.black, // Set background to black
=======
                color: theme.colorScheme.background,
>>>>>>> Stashed changes
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    confettiManager.buildCorrectConfetti(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        buildTimerCard(
                            formatTime(_quizTimer.secondsPassed), context),
                        Expanded(
                          child: Center(
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: _triggerTTSSpeech,
                                          style: ElevatedButton.styleFrom(
                                            shape: const CircleBorder(),
                                            elevation: 8,
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                            padding: EdgeInsets.all(
                                                screenWidth * 0.1),
                                          ),
                                          child: Icon(
                                            Icons.record_voice_over,
<<<<<<< Updated upstream
                                            size: screenWidth * 0.1,
                                            color: Colors.white,
=======
                                            size: isTablet ? screenWidth * 0.1 : 60 * adjustedScale,
                                            color: theme.colorScheme.onPrimary,
>>>>>>> Stashed changes
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            onPressed: _showHintDialog,
<<<<<<< Updated upstream
                                            icon: const Icon(
                                                Icons.lightbulb_outline,
                                                color: Colors.white),
=======
                                            icon: Icon(Icons.lightbulb_outline, color: theme.colorScheme.onPrimary),
>>>>>>> Stashed changes
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  theme.colorScheme.surface,
                                              shape: const CircleBorder(),
                                            ),
                                            tooltip: 'Show Hint',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme
                                              .surface, // Lighter background for contrast
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20)),
                                          boxShadow: [
                                            BoxShadow(
<<<<<<< Updated upstream
                                              color: Colors.white.withOpacity(
                                                  0.1), // Subtle shadow for dark mode
=======
                                              color: theme.brightness == Brightness.dark
                                                  ? Colors.black.withOpacity(0.3)
                                                  : Colors.grey.withOpacity(0.3),
>>>>>>> Stashed changes
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                buildAnswerButton(
                                                    answerOptions[0],
                                                    () => checkAnswer(
                                                        answerOptions[0])),
                                                const SizedBox(width: 20),
                                                buildAnswerButton(
                                                    answerOptions[1],
                                                    () => checkAnswer(
                                                        answerOptions[1])),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            buildAnswerButton(
                                                answerOptions[2],
                                                () => checkAnswer(
                                                    answerOptions[2])),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 80),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 24,
                      right: 16,
                      child: buildPauseButton(_showPauseDialog, context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
