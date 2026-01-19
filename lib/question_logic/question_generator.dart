import 'dart:math';
import 'enum_values.dart';

class QuestionGenerator {
  List<int> generateTwoRandomNumbers(Operation operation, Range range) {
    final random = Random();
    int num1 = 0;
    int num2 = 0;
    int num3 = 0;
    int correctAnswer = 0;
    int multiplier = 0;
    int divisor = 0;
    int maxLimit = 0;

    switch (operation) {
      case Operation.additionBeginner:
        switch (range) {
          case Range.additionBeginner1to5:
            num1 = random.nextInt(5) + 1;
            num2 = random.nextInt(5) + 1;
            break;
          case Range.additionBeginner6to10:
            num1 = random.nextInt(5) + 6;
            num2 = random.nextInt(5) + 1;
            break;
          case Range.additionBeginnerMixed1to10:
            num1 = random.nextInt(10) + 1;
            num2 = random.nextInt(10) + 1;
            break;
          // New Specific Values
          case Range.additionBeginnerPlus1:
            num1 = random.nextInt(10) + 1;
            num2 = 1;
            break;
          case Range.additionBeginnerPlus2:
            num1 = random.nextInt(10) + 1;
            num2 = 2;
            break;
          case Range.additionBeginnerPlus3:
            num1 = random.nextInt(10) + 1;
            num2 = 3;
            break;
          case Range.additionBeginnerPlus4:
            num1 = random.nextInt(10) + 1;
            num2 = 4;
            break;
          case Range.additionBeginnerPlus5:
            num1 = random.nextInt(10) + 1;
            num2 = 5;
            break;
          default:
            num1 = random.nextInt(5) + 1;
            num2 = random.nextInt(5) + 1;
        }
        correctAnswer = num1 + num2;
        break;

      case Operation.additionIntermediate:
        switch (range) {
          case Range.additionIntermediate10to20:
            do {
              num1 = random.nextInt(11) + 10;
              num2 = random.nextInt(11) + 1;
            } while (num1 + num2 > 20);
            break;
          case Range.additionIntermediate20to30:
            do {
              num1 = random.nextInt(11) + 20;
              num2 = random.nextInt(11) + 1;
            } while (num1 + num2 > 30);
            break;
          case Range.additionIntermediate30to40:
            do {
              num1 = random.nextInt(11) + 30;
              num2 = random.nextInt(11) + 1;
            } while (num1 + num2 > 40);
            break;
          case Range.additionIntermediate40to50:
            do {
              num1 = random.nextInt(11) + 40;
              num2 = random.nextInt(11) + 1;
            } while (num1 + num2 > 50);
            break;
          case Range.additionIntermediateMixed10to50:
            num1 = random.nextInt(41) + 10;
            num2 = random.nextInt(41) + 1;
            if (num1 + num2 > 50) num2 = 50 - num1;
            break;
          // New Specific Values
          case Range.additionIntermediatePlus6:
            num1 = random.nextInt(20) + 1;
            num2 = 6;
            break;
          case Range.additionIntermediatePlus7:
            num1 = random.nextInt(20) + 1;
            num2 = 7;
            break;
          case Range.additionIntermediatePlus8:
            num1 = random.nextInt(20) + 1;
            num2 = 8;
            break;
          case Range.additionIntermediatePlus9:
            num1 = random.nextInt(20) + 1;
            num2 = 9;
            break;
          case Range.additionIntermediatePlus10:
            num1 = random.nextInt(20) + 1;
            num2 = 10;
            break;
          default:
            num1 = random.nextInt(11) + 10;
            num2 = random.nextInt(11) + 1;
        }
        correctAnswer = num1 + num2;
        break;

      case Operation.additionAdvanced:
        switch (range) {
          case Range.additionAdvanced50to100:
            do {
              num1 = random.nextInt(51) + 50;
              num2 = random.nextInt(51) + 1;
            } while (num1 + num2 > 100);
            break;
          case Range.additionAdvanced100to150:
            do {
              num1 = random.nextInt(51) + 100;
              num2 = random.nextInt(51) + 1;
            } while (num1 + num2 > 150);
            break;
          case Range.additionAdvanced150to200:
            do {
              num1 = random.nextInt(51) + 150;
              num2 = random.nextInt(51) + 1;
            } while (num1 + num2 > 200);
            break;
          case Range.additionAdvanced100to200:
            num1 = random.nextInt(101) + 100;
            num2 = random.nextInt(101) + 1;
            if (num1 + num2 > 200) num2 = 200 - num1;
            break;
          case Range.additionAdvancedMixed50to200:
            num1 = random.nextInt(151) + 50;
            num2 = random.nextInt(151) + 1;
            if (num1 + num2 > 200) num2 = 200 - num1;
            break;
          case Range.additionAdvancedMixed1to200:
            num1 = random.nextInt(200) + 1;
            num2 = random.nextInt(200) + 1;
            if (num1 + num2 > 200) num2 = 200 - num1;
            break;
          default:
            num1 = random.nextInt(51) + 50;
            num2 = random.nextInt(51) + 1;
        }
        correctAnswer = num1 + num2;
        break;

      case Operation.subtractionBeginner:
        switch (range) {
          case Range.subtractionBeginner1to10:
            num1 = random.nextInt(10) + 1;
            num2 = random.nextInt(num1) + 1;
            break;
          case Range.subtractionBeginner10to20:
            num1 = random.nextInt(11) + 10;
            num2 = random.nextInt(num1 - 9) + 1;
            break;
          case Range.subtractionBeginnerMixed1to20:
            num1 = random.nextInt(20) + 1;
            num2 = random.nextInt(num1) + 1;
            break;
          // New Specific Values
          case Range.subtractionBeginnerMinus1:
            num2 = 1;
            num1 = random.nextInt(10) + num2;
            break;
          case Range.subtractionBeginnerMinus2:
            num2 = 2;
            num1 = random.nextInt(10) + num2;
            break;
          case Range.subtractionBeginnerMinus3:
            num2 = 3;
            num1 = random.nextInt(10) + num2;
            break;
          case Range.subtractionBeginnerMinus4:
            num2 = 4;
            num1 = random.nextInt(10) + num2;
            break;
          case Range.subtractionBeginnerMinus5:
            num2 = 5;
            num1 = random.nextInt(10) + num2;
            break;
          default:
            num1 = random.nextInt(10) + 1;
            num2 = random.nextInt(num1) + 1;
        }
        correctAnswer = num1 - num2;
        break;

      case Operation.subtractionIntermediate:
        switch (range) {
          case Range.subtractionIntermediate20to30:
            num1 = random.nextInt(11) + 20;
            num2 = random.nextInt(num1 - 19) + 1;
            break;
          case Range.subtractionIntermediate30to40:
            num1 = random.nextInt(11) + 30;
            num2 = random.nextInt(num1 - 29) + 1;
            break;
          case Range.subtractionIntermediate40to50:
            num1 = random.nextInt(11) + 40;
            num2 = random.nextInt(num1 - 39) + 1;
            break;
          case Range.subtractionIntermediateMixed20to50:
            num1 = random.nextInt(31) + 20;
            num2 = random.nextInt(num1 - 19) + 1;
            break;
          // New Specific Values
          case Range.subtractionIntermediateMinus6:
            num2 = 6;
            num1 = random.nextInt(20) + num2;
            break;
          case Range.subtractionIntermediateMinus7:
            num2 = 7;
            num1 = random.nextInt(20) + num2;
            break;
          case Range.subtractionIntermediateMinus8:
            num2 = 8;
            num1 = random.nextInt(20) + num2;
            break;
          case Range.subtractionIntermediateMinus9:
            num2 = 9;
            num1 = random.nextInt(20) + num2;
            break;
          case Range.subtractionIntermediateMinus10:
            num2 = 10;
            num1 = random.nextInt(20) + num2;
            break;
          default:
            num1 = random.nextInt(11) + 20;
            num2 = random.nextInt(num1 - 19) + 1;
        }
        correctAnswer = num1 - num2;
        break;

      case Operation.subtractionAdvanced:
        switch (range) {
          case Range.subtractionAdvanced50to100:
            num1 = random.nextInt(51) + 50;
            num2 = random.nextInt(num1 - 49) + 1;
            break;
          case Range.subtractionAdvanced100to150:
            num1 = random.nextInt(51) + 100;
            num2 = random.nextInt(num1 - 99) + 1;
            break;
          case Range.subtractionAdvanced150to200:
            num1 = random.nextInt(51) + 150;
            num2 = random.nextInt(num1 - 149) + 1;
            break;
          case Range.subtractionAdvancedMixed50to200:
            num1 = random.nextInt(151) + 50;
            num2 = random.nextInt(num1 - 49) + 1;
            break;
          case Range.subtractionAdvancedMixed1to200:
            num1 = random.nextInt(200) + 1;
            num2 = random.nextInt(num1) + 1;
            break;
          default:
            num1 = random.nextInt(51) + 50;
            num2 = random.nextInt(num1 - 49) + 1;
        }
        correctAnswer = num1 - num2;
        break;

      case Operation.multiplicationBeginner:
        int multiplier;
        switch (range) {
          case Range.multiplicationBeginnerX2:
            multiplier = 2;
            break;
          case Range.multiplicationBeginnerX3:
            multiplier = 3;
            break;
          case Range.multiplicationBeginnerX4:
            multiplier = 4;
            break;
          case Range.multiplicationBeginnerX5:
            multiplier = 5;
            break;
          case Range.multiplicationBeginnerMixedX2toX5:
            multiplier = random.nextInt(4) + 2; // 2-5
            break;
          default:
            multiplier = 2;
        }
        num1 = random.nextInt(10) + 1;
        num2 = multiplier;
        correctAnswer = num1 * num2;
        break;

      case Operation.multiplicationIntermediate:
        switch (range) {
          case Range.multiplicationIntermediateX6:
            multiplier = 6;
            break;
          case Range.multiplicationIntermediateX7:
            multiplier = 7;
            break;
          case Range.multiplicationIntermediateX8:
            multiplier = 8;
            break;
          case Range.multiplicationIntermediateX9:
            multiplier = 9;
            break;
          case Range.multiplicationIntermediateMixedX6toX9:
            multiplier = random.nextInt(4) + 6; // 6-9
            break;
          default:
            multiplier = 6;
        }
        num1 = random.nextInt(10) + 1;
        num2 = multiplier;
        correctAnswer = num1 * num2;
        break;

      case Operation.multiplicationAdvanced:
        switch (range) {
          case Range.multiplicationAdvancedX10:
            multiplier = 10;
            break;
          case Range.multiplicationAdvancedX11:
            multiplier = 11;
            break;
          case Range.multiplicationAdvancedX12:
            multiplier = 12;
            break;
          case Range.multiplicationAdvancedMixedX10toX12:
            multiplier = random.nextInt(3) + 10; // 10-12
            break;
          case Range.multiplicationAdvancedMixedX2toX12:
            multiplier = random.nextInt(11) + 2; // 2-12
            break;
          default:
            multiplier = 10;
        }
        num1 = random.nextInt(10) + 1;
        num2 = multiplier;
        correctAnswer = num1 * num2;
        break;

      case Operation.divisionBeginner:
        int divisor;
        switch (range) {
          case Range.divisionBeginnerBy2:
            divisor = 2;
            break;
          case Range.divisionBeginnerBy3:
            divisor = 3;
            break;
          case Range.divisionBeginnerBy4:
            divisor = 4;
            break;
          case Range.divisionBeginnerBy5:
            divisor = 5;
            break;
          case Range.divisionBeginnerMixedBy2to5:
            divisor = random.nextInt(4) + 2; // 2-5
            break;
          default:
            divisor = 2;
        }
        // Ensure we only generate problems with the selected divisor
        correctAnswer = random.nextInt(10) + 1; // 1-10
        num1 = correctAnswer * divisor;
        num2 = divisor;
        return [num1, num2, correctAnswer];

      case Operation.divisionIntermediate:
        switch (range) {
          case Range.divisionIntermediateBy6:
            divisor = 6;
            break;
          case Range.divisionIntermediateBy7:
            divisor = 7;
            break;
          case Range.divisionIntermediateBy8:
            divisor = 8;
            break;
          case Range.divisionIntermediateBy9:
            divisor = 9;
            break;
          case Range.divisionIntermediateMixedBy6to9:
            divisor = random.nextInt(4) + 6; // 6-9
            break;
          default:
            divisor = 6;
        }
        correctAnswer = random.nextInt(10) + 1;
        num1 = correctAnswer * divisor;
        num2 = divisor;
        break;

      case Operation.divisionAdvanced:
        num2 = random.nextInt(9) + 2; // 2-10
        correctAnswer = random.nextInt(10) + 1; // 1-10
        num1 = num2 * correctAnswer;
        break;

      case Operation.lcmBeginner:
      case Operation.lcmIntermediate:
      case Operation.lcmAdvanced:
        int maxLimit;
        bool isThreeNumbers = false;
        switch (range) {
          case Range.lcmBeginnerUpto10:
            maxLimit = 10;
            break;
          case Range.lcmBeginnerUpto20:
          case Range.lcmBeginnerMixedUpto20:
            maxLimit = 20;
            break;
          case Range.lcmIntermediateUpto30:
            maxLimit = 30;
            break;
          case Range.lcmIntermediateUpto40:
            maxLimit = 40;
            break;
          case Range.lcmIntermediateUpto50:
            maxLimit = 50;
            break;
          case Range.lcmIntermediateUpto60:
          case Range.lcmIntermediateMixedUpto60:
            maxLimit = 60;
            break;
          case Range.lcmAdvancedUpto70:
            maxLimit = 70;
            break;
          case Range.lcmAdvancedUpto80:
            maxLimit = 80;
            break;
          case Range.lcmAdvancedUpto90:
            maxLimit = 90;
            break;
          case Range.lcmAdvancedUpto100:
          case Range.lcmAdvancedMixedUpto100:
            maxLimit = 100;
            break;
          case Range.lcmAdvanced3NumbersUpto10:
            maxLimit = 10;
            isThreeNumbers = true;
            break;
          case Range.lcmAdvanced3NumbersUpto20:
            maxLimit = 20;
            isThreeNumbers = true;
            break;
          case Range.lcmAdvanced3NumbersUpto30:
            maxLimit = 30;
            isThreeNumbers = true;
            break;
          case Range.lcmAdvanced3NumbersUpto40:
            maxLimit = 40;
            isThreeNumbers = true;
            break;
          case Range.lcmAdvanced3NumbersUpto50:
          case Range.lcmAdvancedMixed3NumbersUpto50:
            maxLimit = 50;
            isThreeNumbers = true;
            break;
          default:
            maxLimit = 10;
        }
        if (isThreeNumbers) {
          List<int> nums = _generateThreeUniqueRandomNumbers(maxLimit);
          correctAnswer = calculateLCM3(nums[0], nums[1], nums[2]);
          return [...nums, correctAnswer];
        } else {
          num1 = random.nextInt(maxLimit) + 1;
          num2 = random.nextInt(maxLimit) + 1;
          correctAnswer = calculateLCM(num1, num2);
        }
        break;

      case Operation.gcfBeginner:
      case Operation.gcfIntermediate:
      case Operation.gcfAdvanced:
        switch (range) {
          case Range.gcfBeginnerUpto10:
            maxLimit = 10;
            break;
          case Range.gcfBeginnerUpto20:
          case Range.gcfBeginnerMixedUpto20:
            maxLimit = 20;
            break;
          case Range.gcfIntermediateUpto30:
            maxLimit = 30;
            break;
          case Range.gcfIntermediateUpto40:
            maxLimit = 40;
            break;
          case Range.gcfIntermediateUpto50:
            maxLimit = 50;
            break;
          case Range.gcfIntermediateUpto60:
          case Range.gcfIntermediateMixedUpto60:
            maxLimit = 60;
            break;
          case Range.gcfAdvancedUpto70:
            maxLimit = 70;
            break;
          case Range.gcfAdvancedUpto80:
            maxLimit = 80;
            break;
          case Range.gcfAdvancedUpto90:
            maxLimit = 90;
            break;
          case Range.gcfAdvancedUpto100:
          case Range.gcfAdvancedMixedUpto100:
            maxLimit = 100;
            break;
          default:
            maxLimit = 10;
        }
        num1 = random.nextInt(maxLimit) + 1;
        num2 = random.nextInt(maxLimit) + 1;
        correctAnswer = calculateGCF(num1, num2);
        break;
    }

    return num3 != 0
        ? [num1, num2, num3, correctAnswer]
        : [num1, num2, correctAnswer];
  }

  int calculateGCF(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  int calculateLCM(int a, int b) {
    return (a * b) ~/ calculateGCF(a, b);
  }

  int calculateLCM3(int a, int b, int c) {
    int lcm = calculateLCM(a, b);
    return calculateLCM(lcm, c);
  }

  List<int> _generateThreeUniqueRandomNumbers(int maxLimit) {
    final random = Random();
    Set<int> nums = {};
    while (nums.length < 3) {
      nums.add(random.nextInt(maxLimit) + 1);
    }
    return nums.toList();
  }
}
