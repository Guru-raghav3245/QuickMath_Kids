import 'package:quickmath_kids/question_logic/enum_values.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TTSHelper {
  final Function(String, WidgetRef) triggerTTS;

  TTSHelper(this.triggerTTS);

  void playSpeech(Operation selectedOperation, List<int> numbers, WidgetRef ref) {
    String operatorWord = '';
    switch (selectedOperation) {
      case Operation.additionBeginner:
      case Operation.additionIntermediate:
      case Operation.additionAdvanced:
        operatorWord = 'plus';
        break;
      case Operation.subtractionBeginner:
      case Operation.subtractionIntermediate:
      case Operation.subtractionAdvanced:
        operatorWord = 'minus';
        break;
      case Operation.multiplicationBeginner:
      case Operation.multiplicationIntermediate:
      case Operation.multiplicationAdvanced:
        operatorWord = 'times';
        break;
      case Operation.divisionBeginner:
      case Operation.divisionIntermediate:
      case Operation.divisionAdvanced:
        operatorWord = 'divided by';
        break;
      case Operation.lcmBeginner:
      case Operation.lcmIntermediate:
      case Operation.lcmAdvanced:
        operatorWord = 'LCM of ';
        break;
      case Operation.gcfBeginner:
      case Operation.gcfIntermediate:
      case Operation.gcfAdvanced:
        operatorWord = 'GCF of ';
        break;
    }

    String questionText;
    switch (selectedOperation) {
      case Operation.lcmBeginner:
      case Operation.lcmIntermediate:
      case Operation.lcmAdvanced:
        questionText = numbers.length >= 3
            ? 'LCM of ${numbers[0]}, ${numbers[1]}, and ${numbers[2]}'
            : 'LCM of ${numbers[0]} and ${numbers[1]}';
        break;
      case Operation.gcfBeginner:
      case Operation.gcfIntermediate:
      case Operation.gcfAdvanced:
        questionText = '$operatorWord ${numbers[0]} and ${numbers[1]}';
        break;
      default:
        questionText = '${numbers[0]} $operatorWord ${numbers[1]} equals?';
    }

    triggerTTS(questionText, ref);
  }
}