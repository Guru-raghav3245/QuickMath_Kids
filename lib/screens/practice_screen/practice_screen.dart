import 'package:flutter/material.dart';
import 'package:QuickMath_Kids/question_logic/question_generator.dart';
import 'package:QuickMath_Kids/screens/practice_screen/modals/quit_modal.dart';
import 'package:QuickMath_Kids/screens/practice_screen/modals/pause_modal.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/timer_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/tts_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/hint_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/confetti_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/answer_option_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/operation_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/ui/timer_card.dart';
import 'package:QuickMath_Kids/screens/practice_screen/ui/answer_button.dart';
import 'package:QuickMath_Kids/screens/practice_screen/ui/pause_button.dart';
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
  final bool isDarkMode;

  const PracticeScreen(
    this.switchToResultScreen,
    this.switchToStartScreen,
    this.triggerTTS,
    this.selectedOperation,
    this.selectedRange,
    this.sessionTimeLimit, {
    required this.isDarkMode,
    super.key,
  });

  @override
  _PracticeScreenState createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<int> numbers = [0, 0, 0];
  List<int> answerOptions = [];
  List<String> answeredQuestions = [];
  List<bool> answeredCorrectly = [];
  List<Map<String, dynamic>> _wrongQuestions = [];
  List<String> _wrongQuestionsToShowThisSession = [];
  List<String> _shownWrongQuestionsThisSession = [];
  List<String> _answeredQuestionsThisSession = [];
  List<String> _wrongQuestionsThisSession = [];
  bool _isInitialized = false;

  int correctAnswer = 0;
  String currentHintMessage = '';
  bool hasListenedToQuestion = false;

  final HintManager hintManager = HintManager();
  final QuizTimer _quizTimer = QuizTimer();
  late ConfettiManager confettiManager;
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
  }

  Future<void> _initializeScreen() async {
    await _loadWrongQuestions();
    setState(() {
      _setInitialQuestion();
      _updateHintMessage();
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _quizTimer.stopTimer();
    confettiManager.dispose();
    super.dispose();
  }

  void stopTimer() => _quizTimer.stopTimer();
  void pauseTimer() => _quizTimer.pauseTimer();
  void resumeTimer() => _quizTimer.resumeTimer();

  Future<void> _loadWrongQuestions() async {
    List<Map<String, dynamic>> allWrongQuestions =
        await WrongQuestionsService.getWrongQuestions();

    setState(() {
      _wrongQuestions = [];
      _wrongQuestionsToShowThisSession = [];

      // Filter questions matching current operation and range
      final currentOperation =
          widget.selectedOperation.toString().split('.').last;
      for (var question in allWrongQuestions) {
        String category = question['category']?.toString() ?? '';
        String questionText = question['question']?.toString() ?? '';
        String operationFromCategory = category.split(' - ').first;
        String rangeFromCategory = category.split(' - ').last;

        if (operationFromCategory == currentOperation &&
            rangeFromCategory == widget.selectedRange) {
          _wrongQuestions.add(question);
          _wrongQuestionsToShowThisSession.add(questionText);
        }
      }

      // Reset tracking lists for new session
      _shownWrongQuestionsThisSession.clear();
      _answeredQuestionsThisSession.clear();
      _wrongQuestionsThisSession.clear();
    });
  }

  void _setInitialQuestion() {
    if (_wrongQuestionsToShowThisSession.isNotEmpty) {
      // Show all WAQs first before generating new questions
      _useWrongQuestion();
    } else {
      regenerateNumbers();
    }
  }

  void _useWrongQuestion() {
    if (_wrongQuestionsToShowThisSession.isEmpty) {
      regenerateNumbers();
      return;
    }

    String nextQuestionText = _wrongQuestionsToShowThisSession.firstWhere(
      (q) => !_shownWrongQuestionsThisSession.contains(q),
      orElse: () => '',
    );

    if (nextQuestionText.isNotEmpty) {
      setState(() {
        numbers = _parseQuestion(nextQuestionText);
        correctAnswer =
            _calculateCorrectAnswer(numbers, widget.selectedOperation);
        answerOptions = generateAnswerOptions(correctAnswer);
        _shownWrongQuestionsThisSession.add(nextQuestionText);
        _answeredQuestionsThisSession.add(nextQuestionText);
      });
    } else {
      // All WAQs shown, proceed with normal questions
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
    int attempts = 0;
    const maxAttempts = 100;
    String questionText;

    do {
      numbers = QuestionGenerator().generateTwoRandomNumbers(
          widget.selectedOperation, widget.selectedRange);

      if (widget.selectedOperation == Operation.lcm ||
          widget.selectedOperation == Operation.gcf) {
        correctAnswer = numbers.last;
        numbers = numbers.sublist(0, numbers.length - 1);
      } else {
        if (numbers.length >= 2) {
          switch (widget.selectedOperation) {
            case Operation.addition_2A:
            case Operation.addition_A:
            case Operation.addition_B:
              correctAnswer = numbers[0] + numbers[1];
              break;
            case Operation.subtraction_A:
            case Operation.subtraction_B:
              correctAnswer = numbers[0] - numbers[1];
              break;
            case Operation.multiplication_C:
              correctAnswer = numbers[0] * numbers[1];
              break;
            case Operation.division_C:
            case Operation.division_D:
              correctAnswer = numbers[0] ~/ numbers[1];
              break;
            default:
              correctAnswer = 0;
          }
        } else {
          correctAnswer = 0;
        }
      }

      questionText = _formatQuestionText();
      attempts++;
    } while (_answeredQuestionsThisSession.contains(questionText) &&
        attempts < maxAttempts);

    if (attempts >= maxAttempts) {
      int num1, num2;
      do {
        num1 = (DateTime.now().millisecondsSinceEpoch % 10) + 1;
        num2 = (DateTime.now().millisecondsSinceEpoch % 10) + 1;
        numbers = [num1, num2];

        if (widget.selectedOperation == Operation.lcm ||
            widget.selectedOperation == Operation.gcf) {
          correctAnswer = widget.selectedOperation == Operation.lcm
              ? _lcm(num1, num2)
              : _gcd(num1, num2);
        } else {
          switch (widget.selectedOperation) {
            case Operation.addition_2A:
            case Operation.addition_A:
            case Operation.addition_B:
              correctAnswer = num1 + num2;
              break;
            case Operation.subtraction_A:
            case Operation.subtraction_B:
              correctAnswer = num1 - num2;
              break;
            case Operation.multiplication_C:
              correctAnswer = num1 * num2;
              break;
            case Operation.division_C:
            case Operation.division_D:
              if (num2 != 0) {
                correctAnswer = num1 ~/ num2;
              } else {
                num2 = 1;
                correctAnswer = num1 ~/ num2;
              }
              break;
            default:
              correctAnswer = 0;
          }
        }

        questionText = _formatQuestionText();
      } while (_answeredQuestionsThisSession.contains(questionText));
    }

    answerOptions = generateAnswerOptions(correctAnswer);
    _answeredQuestionsThisSession.add(questionText);
  }

  void checkAnswer(int selectedAnswer) {
    bool isCorrect = selectedAnswer == correctAnswer;
    String currentQuestion = _formatQuestionText();

    setState(() {
      // Record current answer with correct/wrong status (EXACTLY AS YOU HAD IT)
      answeredQuestions.add('$currentQuestion = $selectedAnswer '
          '(${isCorrect ? "Correct" : "Wrong, The correct answer is $correctAnswer"})');
      answeredCorrectly.add(isCorrect);

      // Update WAQ tracking (EXACTLY AS YOU HAD IT)
      if (!isCorrect) {
        if (!_wrongQuestionsThisSession.contains(currentQuestion)) {
          _wrongQuestionsThisSession.add(currentQuestion);
          WrongQuestionsService.saveWrongQuestion(
            question: currentQuestion,
            userAnswer: selectedAnswer,
            correctAnswer: correctAnswer,
            category:
                '${widget.selectedOperation.toString().split('.').last} - ${widget.selectedRange}',
          );
        }
      } else if (_wrongQuestionsToShowThisSession.contains(currentQuestion)) {
        WrongQuestionsService.updateWrongQuestion(currentQuestion,
            correct: true);
      }

      // Play confetti for correct answers (EXACTLY AS YOU HAD IT)
      if (isCorrect) {
        confettiManager.correctConfettiController.play();
      }

      // ONLY CHANGE: Modified WAQ sequencing logic
      if (_wrongQuestionsToShowThisSession.isNotEmpty) {
        // Find next unshown WAQ
        String? nextWAQ = _wrongQuestionsToShowThisSession.firstWhere(
          (q) => !_shownWrongQuestionsThisSession.contains(q),
          orElse: () => '',
        );

        if (nextWAQ.isNotEmpty) {
          numbers = _parseQuestion(nextWAQ);
          correctAnswer =
              _calculateCorrectAnswer(numbers, widget.selectedOperation);
          answerOptions = generateAnswerOptions(correctAnswer);
          _shownWrongQuestionsThisSession.add(nextWAQ);
        } else {
          // No more WAQs - proceed normally
          regenerateNumbers();
        }
      } else {
        // No WAQs - proceed normally
        regenerateNumbers();
      }

      // Track all answered questions (EXACTLY AS YOU HAD IT)
      _answeredQuestionsThisSession.add(currentQuestion);
    });

    // Trigger TTS for the new question (EXACTLY AS YOU HAD IT)
    _triggerTTSSpeech();
  }

  int _calculateCorrectAnswer(List<int> numbers, Operation operation) {
    if (numbers.length < 2) return 0;
    switch (operation) {
      case Operation.addition_2A:
      case Operation.addition_A:
      case Operation.addition_B:
        return numbers[0] + numbers[1];
      case Operation.subtraction_A:
      case Operation.subtraction_B:
        return numbers[0] - numbers[1];
      case Operation.multiplication_C:
        return numbers[0] * numbers[1];
      case Operation.division_C:
      case Operation.division_D:
        return numbers[0] ~/ numbers[1];
      case Operation.lcm:
        return _lcm(numbers[0], numbers[1]);
      case Operation.gcf:
        return _gcd(numbers[0], numbers[1]);
    }
  }

  int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  int _lcm(int a, int b) {
    return (a * b) ~/ _gcd(a, b);
  }

  List<int> _parseQuestion(String questionText) {
    RegExp regExp = RegExp(r'\d+');
    return regExp
        .allMatches(questionText)
        .map((m) => int.parse(m[0] ?? '0'))
        .toList();
  }

  String _formatQuestionText() {
    if (widget.selectedOperation == Operation.lcm) {
      if (widget.selectedRange.contains('3 numbers')) {
        return 'LCM of ${numbers[0]}, ${numbers[1]}, ${numbers[2]}';
      } else {
        return 'LCM of ${numbers[0]}, ${numbers[1]}';
      }
    } else if (widget.selectedOperation == Operation.gcf) {
      return 'GCF of ${numbers[0]}, ${numbers[1]}';
    } else {
      return '${numbers[0]} ${OperatorHelper.getOperatorSymbol(widget.selectedOperation)} ${numbers[1]}';
    }
  }

  void _triggerTTSSpeech() {
    // Use the current numbers after ensuring they're updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ttsHelper.playSpeech(widget.selectedOperation, numbers);
      setState(() {
        hasListenedToQuestion = true;
      });
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
          title: Text('Hint',
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: theme.colorScheme.onSurface)),
          content: Text(currentHintMessage,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurface)),
          backgroundColor: theme.colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close',
                  style: TextStyle(color: theme.colorScheme.primary)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = AppTheme.getTheme(ref, widget.isDarkMode, context);
        final screenWidth = MediaQuery.of(context).size.width;
        final scale = screenWidth / 360;
        final adjustedScale = screenWidth > 600 ? scale.clamp(0.8, 1.2) : scale;
        final isTablet = screenWidth > 600;

        int displayTime = widget.sessionTimeLimit != null
            ? (widget.sessionTimeLimit! - _quizTimer.secondsPassed)
            : _quizTimer.secondsPassed;
        if (widget.sessionTimeLimit != null && displayTime < 0) displayTime = 0;

        if (!_isInitialized) {
          return Theme(
            data: theme,
            child: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Theme(
          data: theme,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Practice',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: theme.colorScheme.onPrimary)),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
              actions: [
                Padding(
                  padding: EdgeInsets.all(8.0 * adjustedScale),
                  child: ElevatedButton.icon(
                    onPressed: _showQuitDialog,
                    icon: Icon(Icons.exit_to_app_rounded,
                        color: theme.colorScheme.onPrimary),
                    label: Text('Quit',
                        style: TextStyle(color: theme.colorScheme.onPrimary)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.error),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0 * adjustedScale),
                  child: ElevatedButton.icon(
                    onPressed: endQuiz,
                    icon: Icon(Icons.assessment,
                        color: theme.colorScheme.onPrimary),
                    label: Text('Results',
                        style: TextStyle(color: theme.colorScheme.onPrimary)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Container(
                color: theme.colorScheme.background,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    confettiManager.buildCorrectConfetti(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 16 * adjustedScale),
                        buildTimerCard(
                            formatTime(_quizTimer.secondsPassed), context),
                        Expanded(
                          child: Center(
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
                                        padding: EdgeInsets.all(isTablet
                                            ? screenWidth * 0.1
                                            : 40 * adjustedScale),
                                      ),
                                      child: Icon(
                                        Icons.record_voice_over,
                                        size: isTablet
                                            ? screenWidth * 0.1
                                            : 60 * adjustedScale,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        onPressed: _showHintDialog,
                                        icon: Icon(Icons.lightbulb_outline,
                                            color: theme.iconTheme.color),
                                        style: IconButton.styleFrom(
                                          backgroundColor:
                                              Colors.deepOrangeAccent,
                                          shape: const CircleBorder(),
                                        ),
                                        tooltip: 'Show Hint',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: isTablet ? 40 : 40 * adjustedScale),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0 * adjustedScale),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20 * adjustedScale)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.brightness ==
                                                  Brightness.dark
                                              ? Colors.black.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(16 * adjustedScale),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            buildAnswerButton(
                                              answerOptions[0],
                                              () =>
                                                  checkAnswer(answerOptions[0]),
                                            ),
                                            SizedBox(
                                                width: isTablet
                                                    ? 20
                                                    : 12 * adjustedScale),
                                            buildAnswerButton(
                                              answerOptions[1],
                                              () =>
                                                  checkAnswer(answerOptions[1]),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: isTablet
                                                ? 20
                                                : 12 * adjustedScale),
                                        buildAnswerButton(
                                          answerOptions[2],
                                          () => checkAnswer(answerOptions[2]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: isTablet ? 80 : 40 * adjustedScale),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 24 * adjustedScale,
                      right: 16 * adjustedScale,
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
