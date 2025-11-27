import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:QuickMath_Kids/question_logic/question_generator.dart';
import 'package:QuickMath_Kids/question_logic/enum_values.dart';
import 'package:QuickMath_Kids/screens/practice_screen/modals/quit_modal.dart';
import 'package:QuickMath_Kids/screens/practice_screen/modals/inactivity_modal.dart';
import 'package:QuickMath_Kids/screens/practice_screen/modals/pause_modal.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/timer_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/tts_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/hint_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/confetti_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/answer_option_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/helpers/operation_helper.dart';
import 'package:QuickMath_Kids/screens/practice_screen/ui/timer_card.dart';
import 'package:QuickMath_Kids/screens/practice_screen/ui/answer_button.dart';
import 'package:QuickMath_Kids/question_logic/wrong_answer_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:QuickMath_Kids/app_theme.dart';
import 'package:QuickMath_Kids/services/billing_service.dart';
import 'package:QuickMath_Kids/screens/settings_screen.dart';
import 'package:QuickMath_Kids/screens/result_screen/result_screen.dart';
import 'package:QuickMath_Kids/screens/home_screen/home_page.dart';

class PracticeScreen extends StatefulWidget {
  final Function(String, WidgetRef) triggerTTS;
  final Operation selectedOperation;
  final Range selectedRange;
  final int? sessionTimeLimit;

  const PracticeScreen({
    required this.selectedOperation,
    required this.selectedRange,
    this.sessionTimeLimit,
    required this.triggerTTS,
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
  bool _isWrongAnswerQuestion = false;
  bool _isProcessingAnswer = false;

  int correctAnswer = 0;
  String currentHintMessage = '';
  bool hasListenedToQuestion = false;

  final HintManager hintManager = HintManager();
  final QuizTimer _quizTimer = QuizTimer();
  late ConfettiManager confettiManager;
  late TTSHelper _ttsHelper;
  Timer? _inactivityTimer;

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
    _startInactivityTimer();
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
    _inactivityTimer?.cancel();
    confettiManager.dispose();
    super.dispose();
  }

  void stopTimer() => _quizTimer.stopTimer();
  void pauseTimer() => _quizTimer.pauseTimer();
  void resumeTimer() => _quizTimer.resumeTimer();

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        pauseTimer();
        _inactivityTimer?.cancel();
        _showNoActivityModal();
      }
    });
  }

  void _showNoActivityModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return InActivityModal(
          onResume: () {
            Navigator.pop(context);
            resumeTimer();
            _startInactivityTimer();
          },
        );
      },
    );
  }

  void _showPauseDialog() {
    pauseTimer();
    _startInactivityTimer();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PauseDialog(
          onResume: () {
            resumeTimer();
            _startInactivityTimer();
          },
        );
      },
    );
  }

  Future<void> _loadWrongQuestions() async {
    List<Map<String, dynamic>> allWrongQuestions =
        await WrongQuestionsService.getWrongQuestions();

    setState(() {
      _wrongQuestions = [];
      _wrongQuestionsToShowThisSession = [];

      final currentOperation =
          widget.selectedOperation.toString().split('.').last;
      final rangeDisplayName = getRangeDisplayName(widget.selectedRange);
      for (var question in allWrongQuestions) {
        String category = question['category']?.toString() ?? '';
        String questionText = question['question']?.toString() ?? '';
        String operationFromCategory = category.split(' - ').first;
        String rangeFromCategory = category.split(' - ').last;

        if (operationFromCategory == currentOperation &&
            rangeFromCategory == rangeDisplayName) {
          _wrongQuestions.add(question);
          _wrongQuestionsToShowThisSession.add(questionText);
        }
      }

      _shownWrongQuestionsThisSession.clear();
      _answeredQuestionsThisSession.clear();
      _wrongQuestionsThisSession.clear();
    });
  }

  void _setInitialQuestion() {
    if (_wrongQuestionsToShowThisSession.isNotEmpty) {
      _useWrongQuestion();
      _isWrongAnswerQuestion = true;
    } else {
      _generateNewQuestion();
      _isWrongAnswerQuestion = false;
    }
  }

  void _generateNewQuestion() {
    const maxAttempts = 100;
    int attempts = 0;
    String questionText = '';
    List<int> generatedNumbers;

    do {
      generatedNumbers = QuestionGenerator().generateTwoRandomNumbers(
          widget.selectedOperation, widget.selectedRange);

      if (widget.selectedOperation == Operation.lcmBeginner ||
          widget.selectedOperation == Operation.lcmIntermediate ||
          widget.selectedOperation == Operation.lcmAdvanced) {
        if (widget.selectedRange.toString().contains('3Numbers')) {
          numbers = generatedNumbers.sublist(0, 3);
          correctAnswer = generatedNumbers[3];
        } else {
          numbers = generatedNumbers.sublist(0, 2);
          correctAnswer = generatedNumbers[2];
        }
      } else {
        numbers = generatedNumbers.sublist(0, 2);
        correctAnswer = generatedNumbers[2];
      }

      questionText = _formatQuestionText();
      attempts++;
    } while (_answeredQuestionsThisSession.contains(questionText) &&
        attempts < maxAttempts);

    setState(() {
      answerOptions = generateAnswerOptions(correctAnswer);
      _answeredQuestionsThisSession.add(questionText);
    });
  }

  void _useWrongQuestion() {
    if (_wrongQuestionsToShowThisSession.isEmpty) {
      _generateNewQuestion();
      _isWrongAnswerQuestion = false;
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
        _isWrongAnswerQuestion = true;
      });
    } else {
      _generateNewQuestion();
      _isWrongAnswerQuestion = false;
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

  void checkAnswer(int selectedAnswer, WidgetRef ref) async {
    if (_isProcessingAnswer) return;
    try {
      setState(() {
        _isProcessingAnswer = true;
      });

      _startInactivityTimer();
      bool isCorrect = selectedAnswer == correctAnswer;
      String currentQuestion = _formatQuestionText();

      setState(() {
        answeredQuestions.add('$currentQuestion = $selectedAnswer '
            '(${isCorrect ? "Correct" : "Wrong, The correct answer is $correctAnswer"})');
        answeredCorrectly.add(isCorrect);
        if (isCorrect) {
          confettiManager.correctConfettiController.play();
        } else {
          confettiManager.wrongConfettiController.play();
        }
        if (_wrongQuestionsToShowThisSession.isNotEmpty) {
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
            _isWrongAnswerQuestion = true;
          } else {
            _generateNewQuestion();
            _isWrongAnswerQuestion = false;
          }
        } else {
          _generateNewQuestion();
          _isWrongAnswerQuestion = false;
        }
        _answeredQuestionsThisSession.add(currentQuestion);
      });

      Future.microtask(() async {
        if (!isCorrect) {
          if (!_wrongQuestionsThisSession.contains(currentQuestion)) {
            _wrongQuestionsThisSession.add(currentQuestion);
            await WrongQuestionsService.saveWrongQuestion(
              question: currentQuestion,
              userAnswer: selectedAnswer,
              correctAnswer: correctAnswer,
              category:
                  '${widget.selectedOperation.toString().split('.').last} - ${getRangeDisplayName(widget.selectedRange)}',
            );
          }
        } else if (_wrongQuestionsToShowThisSession.contains(currentQuestion)) {
          await WrongQuestionsService.updateWrongQuestion(currentQuestion,
              correct: true);
        }
      });
      _triggerTTSSpeech(ref);

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isProcessingAnswer = false;
        });
      }
    } catch (e, stackTrace) {
      print("Error in checkAnswer: $e");
      print(stackTrace);
      if (mounted) {
        setState(() {
          _isProcessingAnswer = false;
        });
      }
    }
  }

  int _calculateCorrectAnswer(List<int> numbers, Operation operation) {
    if (numbers.length < 2) return 0;
    switch (operation) {
      case Operation.additionBeginner:
      case Operation.additionIntermediate:
      case Operation.additionAdvanced:
        return numbers[0] + numbers[1];
      case Operation.subtractionBeginner:
      case Operation.subtractionIntermediate:
      case Operation.subtractionAdvanced:
        return numbers[0] - numbers[1];
      case Operation.multiplicationBeginner:
      case Operation.multiplicationIntermediate:
      case Operation.multiplicationAdvanced:
        return numbers[0] * numbers[1];
      case Operation.divisionBeginner:
      case Operation.divisionIntermediate:
      case Operation.divisionAdvanced:
        return numbers[0] ~/ numbers[1];
      case Operation.lcmBeginner:
      case Operation.lcmIntermediate:
      case Operation.lcmAdvanced:
        return _lcm(numbers[0], numbers[1]);
      case Operation.gcfBeginner:
      case Operation.gcfIntermediate:
      case Operation.gcfAdvanced:
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
    if (widget.selectedOperation == Operation.lcmBeginner ||
        widget.selectedOperation == Operation.lcmIntermediate ||
        widget.selectedOperation == Operation.lcmAdvanced) {
      if (widget.selectedRange.toString().contains('3Numbers')) {
        return 'LCM of ${numbers[0]}, ${numbers[1]}, ${numbers[2]}';
      } else {
        return 'LCM of ${numbers[0]}, ${numbers[1]}';
      }
    } else if (widget.selectedOperation == Operation.gcfBeginner ||
        widget.selectedOperation == Operation.gcfIntermediate ||
        widget.selectedOperation == Operation.gcfAdvanced) {
      return 'GCF of ${numbers[0]}, ${numbers[1]}';
    } else {
      return '${numbers[0]} ${OperatorHelper.getOperatorSymbol(widget.selectedOperation)} ${numbers[1]}';
    }
  }

  void _triggerTTSSpeech(WidgetRef ref) {
    _startInactivityTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ttsHelper.playSpeech(widget.selectedOperation, numbers, ref);
      setState(() {
        hasListenedToQuestion = true;
      });
    });
  }

  void endQuiz() {
    _startInactivityTimer();
    stopTimer();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          answeredQuestions: answeredQuestions,
          answeredCorrectly: answeredCorrectly,
          totalTime: _quizTimer.secondsPassed,
          operation: widget.selectedOperation,
          range: widget.selectedRange,
          timeLimit: widget.sessionTimeLimit,
        ),
      ),
    );
  }

  void _showQuitDialog() {
    _startInactivityTimer();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QuitDialog(
          onQuit: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => Consumer(
                  builder: (context, ref, child) {
                    final isDarkMode = ref.watch(darkModeProvider);
                    return const StartScreen();
                  },
                ),
              ),
              (route) => false,
            );
          },
        );
      },
    );
  }

  void _showHintDialog() {
    _startInactivityTimer();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            'Hint',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            currentHintMessage,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
          backgroundColor: theme.colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startInactivityTimer();
              },
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
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
        final isDarkMode = ref.watch(darkModeProvider);
        final theme = AppTheme.getTheme(ref, isDarkMode, context);
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
              title: Text(
                'Practice',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.7),
              actions: [
                Padding(
                  padding: EdgeInsets.all(8.0 * adjustedScale),
                  child: ElevatedButton.icon(
                    onPressed: _showQuitDialog,
                    icon: Icon(Icons.exit_to_app_rounded,
                        color: theme.colorScheme.onPrimary),
                    label: Text(
                      'Quit',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
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
                    label: Text(
                      'Results',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
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
                    Align(
                      alignment: Alignment.topCenter,
                      child: confettiManager.buildCorrectConfetti(),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: confettiManager.buildWrongConfetti(),
                    ),
                    if (_isWrongAnswerQuestion)
                      Positioned(
                        top: 8.0 * adjustedScale,
                        right: 8.0 * adjustedScale,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.0 * adjustedScale,
                            vertical: 4.0 * adjustedScale,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius:
                                BorderRadius.circular(5 * adjustedScale),
                          ),
                          child: Text(
                            'Previous Wrong Answer',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12 * adjustedScale,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 80 * adjustedScale),
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
                                      onPressed: () => _triggerTTSSpeech(ref),
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
                                          color: isDarkMode
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
                                              () => checkAnswer(
                                                  answerOptions[0], ref),
                                            ),
                                            SizedBox(
                                                width: isTablet
                                                    ? 20
                                                    : 12 * adjustedScale),
                                            buildAnswerButton(
                                              answerOptions[1],
                                              () => checkAnswer(
                                                  answerOptions[1], ref),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            height: isTablet
                                                ? 20
                                                : 12 * adjustedScale),
                                        buildAnswerButton(
                                          answerOptions[2],
                                          () => checkAnswer(
                                              answerOptions[2], ref),
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
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet
                                ? 40.0 * adjustedScale
                                : 24.0 * adjustedScale,
                            vertical: 8.0 * adjustedScale,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 200 * adjustedScale,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface
                                      .withOpacity(0.7),
                                  borderRadius:
                                      BorderRadius.circular(30 * adjustedScale),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0 * adjustedScale,
                                  vertical: 8.0 * adjustedScale,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      ref.watch(volumeProvider) > 0.66
                                          ? Icons.volume_up
                                          : ref.watch(volumeProvider) > 0.33
                                              ? Icons.volume_down
                                              : Icons.volume_mute,
                                      color: theme.colorScheme.primary,
                                      size: isTablet
                                          ? 28 * adjustedScale
                                          : 20 * adjustedScale,
                                    ),
                                    SizedBox(width: 8 * adjustedScale),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor:
                                              theme.colorScheme.primary,
                                          inactiveTrackColor: theme
                                              .colorScheme.onSurface
                                              .withOpacity(0.1),
                                          thumbColor: theme.colorScheme.primary,
                                          overlayColor: theme
                                              .colorScheme.primary
                                              .withOpacity(0.2),
                                          trackHeight: isTablet
                                              ? 6 * adjustedScale
                                              : 4 * adjustedScale,
                                          thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: isTablet
                                                ? 12 * adjustedScale
                                                : 8 * adjustedScale,
                                          ),
                                          overlayShape: RoundSliderOverlayShape(
                                            overlayRadius: isTablet
                                                ? 16 * adjustedScale
                                                : 12 * adjustedScale,
                                          ),
                                        ),
                                        child: Slider(
                                          value: ref.watch(volumeProvider),
                                          min: 0.0,
                                          max: 1.0,
                                          divisions: 10,
                                          onChanged: (value) {
                                            ref
                                                .read(volumeProvider.notifier)
                                                .state = value;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16 * adjustedScale),
                              Consumer(
                                builder: (context, ref, child) {
                                  final billingService =
                                      ref.watch(billingServiceProvider);
                                  return FloatingActionButton(
                                    onPressed: billingService.isPremium
                                        ? _showPauseDialog
                                        : () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Pause feature is available for premium users',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                    backgroundColor: billingService.isPremium
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.surface
                                            .withOpacity(0.7),
                                    child: Icon(
                                      Icons.pause,
                                      color: billingService.isPremium
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                    tooltip: billingService.isPremium
                                        ? 'Pause Quiz'
                                        : 'Premium feature',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
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
