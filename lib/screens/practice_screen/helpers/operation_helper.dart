import 'package:quickmath_kids/question_logic/enum_values.dart';

class OperatorHelper {
  static String getOperatorSymbol(Operation operation) {
    switch (operation) {
      case Operation.additionBeginner:
      case Operation.additionIntermediate:
      case Operation.additionAdvanced:
        return '+';
      case Operation.subtractionBeginner:
      case Operation.subtractionIntermediate:
      case Operation.subtractionAdvanced:
        return '-';
      case Operation.multiplicationBeginner:
      case Operation.multiplicationIntermediate:
      case Operation.multiplicationAdvanced:
        return 'x';
      case Operation.divisionBeginner:
      case Operation.divisionIntermediate:
      case Operation.divisionAdvanced:
        return '÷';
      case Operation.lcmBeginner:
      case Operation.lcmIntermediate:
      case Operation.lcmAdvanced:
        return 'LCM';
      case Operation.gcfBeginner:
      case Operation.gcfIntermediate:
      case Operation.gcfAdvanced:
        return 'GCF';
    }
  }
}
