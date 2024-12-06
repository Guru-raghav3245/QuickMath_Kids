import 'package:flutter/material.dart';
import 'package:oral_app/question_logic/question_generator.dart';
import 'package:oral_app/screens/practice_screen/quit_modal/quit_modal.dart'; // Import the QuitDialog
import 'package:oral_app/screens/practice_screen/pause_modal.dart';
import 'package:oral_app/screens/practice_screen/quiz_timer.dart'; // Import the new timer utility class

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
  int correctAnswer = 0;
  String resultText = '';
  List<String> answeredQuestions = [];
  List<bool> answeredCorrectly = [];

  final QuizTimer _quizTimer = QuizTimer(); // Use the new timer class

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    regenerateNumbers();
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
    super.dispose();
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

      // Handle different cases based on the number of elements returned
      if (numbers.length == 3) {
        // Standard 2-number operations or 2-number LCM/GCF
        correctAnswer = numbers[2];
      } else if (numbers.length == 4) {
        // 3-number LCM case
        correctAnswer = numbers[3];
      }

      answerOptions = [correctAnswer];
      while (answerOptions.length < 3) {
        int option = QuestionGenerator().generateRandomNumber();
        if (!answerOptions.contains(option)) {
          answerOptions.add(option);
        }
      }
      answerOptions.shuffle(); // Randomize answer options
    });
  }

  void checkAnswer(int selectedAnswer) {
    bool isCorrect = selectedAnswer == correctAnswer;

    setState(() {
      if (widget.selectedOperation == Operation.lcm && numbers.length > 3) {
        // For 3-number LCM
        answeredQuestions.add(
            'LCM of ${numbers[0]}, ${numbers[1]}, and ${numbers[2]} = $selectedAnswer (${isCorrect ? "Correct" : "Wrong, The correct answer is $correctAnswer"})');
      } else {
        // Existing logic for other operations
        answeredQuestions.add(
            '${numbers[0]} ${_getOperatorSymbol(widget.selectedOperation)} ${numbers[1]} = $selectedAnswer (${isCorrect ? "Correct" : "Wrong, The correct answer is $correctAnswer"})');
      }
      answeredCorrectly.add(isCorrect);
    });
  }

  String _getOperatorSymbol(Operation operation) {
    if (operation == Operation.addition_2A ||
        operation == Operation.addition_A ||
        operation == Operation.addition_B) {
      return '+';
    } else if (operation == Operation.subtraction_A ||
        operation == Operation.subtraction_B) {
      return '-';
    } else if (operation == Operation.multiplication_C) {
      return 'x';
    } else if (operation == Operation.division_C ||
        operation == Operation.division_D) {
      return '÷';
    } else if (operation == Operation.lcm) {
      return 'LCM';
    } else if (operation == Operation.lcm) {
      return 'GCF';
    }
    return '';
  }

  void _triggerTTSSpeech() {
    String operatorWord = '';
    switch (widget.selectedOperation) {
      case Operation.addition_2A:
      case Operation.addition_A:
      case Operation.addition_B:
        operatorWord = 'plus';
        break;
      case Operation.subtraction_A:
      case Operation.subtraction_B:
        operatorWord = 'minus';
        break;
      case Operation.multiplication_C:
        operatorWord = 'times';
        break;
      case Operation.division_C:
      case Operation.division_D:
        operatorWord = 'divided by';
        break;
      case Operation.lcm:
        operatorWord = 'LCM of ';
        break;
      case Operation.gcf:
        operatorWord = 'GCF of ';
        break;
      default:
        operatorWord = '';
    }
    String questionText;
    switch (widget.selectedOperation) {
      case Operation.lcm:
        questionText = numbers.length > 3
            ? 'LCM of ${numbers[0]}, ${numbers[1]}, and ${numbers[2]}'
            : 'LCM of ${numbers[0]} and ${numbers[1]}';
        break;
      case Operation.gcf:
        questionText = '$operatorWord ${numbers[0]} and ${numbers[1]}';
      default:
        questionText = '${numbers[0]} $operatorWord ${numbers[1]} equals?';
    }

    widget.triggerTTS(questionText);
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
            widget
                .switchToStartScreen(); // Call the function to switch to start screen
          },
        );
      },
    );
  }

  void _showPauseDialog() {
    pauseTimer(); // Pause the timer when the modal opens
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PauseDialog(onResume: resumeTimer); // Pass the resume function
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    //String questionText =
    // '${numbers[0]} ${_getOperatorSymbol(widget.selectedOperation)} ${numbers[1]} = ?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Quiz'),
        backgroundColor: const Color(0xFF009DDC), // Kumon blue
        actions: [
          ElevatedButton(
            onPressed: _showQuitDialog, // Show the quit dialog
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
            child: const Icon(
              Icons.exit_to_app_rounded,
              size: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: endQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 10, 127, 22),
              ),
              child: const Text(
                'Show Result',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
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
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Display the formatted timer
                      Text(
                        formatTime(_quizTimer.secondsPassed),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      IconButton(
                        icon: const Icon(Icons.speaker),
                        iconSize: 150,
                        color: Colors.black,
                        onPressed: _triggerTTSSpeech,
                      ),
                      const SizedBox(height: 20),
                      /* Text(
                        questionText,
                        style: theme.textTheme.headlineMedium,
                      ),*/
                      const SizedBox(height: 16),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 150,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    checkAnswer(answerOptions[0]);
                                    regenerateNumbers();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                  child: Text(
                                    answerOptions[0].toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 150,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    checkAnswer(answerOptions[1]);
                                    regenerateNumbers();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    backgroundColor: theme.colorScheme.primary,
                                  ),
                                  child: Text(
                                    answerOptions[1].toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                checkAnswer(answerOptions[2]);
                                regenerateNumbers();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                backgroundColor: theme.colorScheme.primary,
                              ),
                              child: Text(
                                answerOptions[2].toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Add the pause button at the bottom-right corner
            Positioned(
              bottom: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: _showPauseDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  fixedSize: const Size(60, 60),
                  padding: EdgeInsets.zero,
                ),
                child: const Center(
                  child: Icon(
                    Icons.pause,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
