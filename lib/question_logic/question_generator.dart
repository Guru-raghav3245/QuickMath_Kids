import 'dart:math';

enum Operation { 
  addition_2A, 
  addition_A,
  addition_B,
  subtraction_A,
  subtraction_B, 
  multiplication_C, 
  division_C,
  division_D,
}

class QuestionGenerator {
  int getRangeLimit(String dropdownValue) {
    // Existing logic...
    
    if (dropdownValue == 'Divided by 2') {
      return 2;
    } else if (dropdownValue == 'Divided by 5') {
      return 5;
    } else if (dropdownValue == 'Divided by 10') {
      return 10;
    } else if (dropdownValue == 'Divided by 20') {
      return 20;
    } else if (dropdownValue == 'Divided by 50') {
      return 50;
    }

    return 10; // Default value
  }

  List<int> generateTwoRandomNumbers(Operation operation, String dropdownValue) {
    final random = Random();
    int num1 = 0;
    int num2 = 0;
    int correctAnswer = 0;

    int rangeLimit = getRangeLimit(dropdownValue);

    if (operation == Operation.addition_2A) {
      if (dropdownValue == 'Upto +5') {
        num1 = random.nextInt(10);
        num2 = random.nextInt(5);
        correctAnswer = num1 + num2;
      } else if (dropdownValue == 'Upto +10') {
        num1 = random.nextInt(10);
        num2 = random.nextInt(10);
        correctAnswer = num1 + num2;
      }
    } else if (operation == Operation.addition_A) {
      if (dropdownValue == 'Sum of 15') {
        do {
          num1 = random.nextInt(16);
          num2 = random.nextInt(16);
        } while (num1 + num2 > 15);
        correctAnswer = num1 + num2;
      } else if (dropdownValue == 'Sum of 18') {
        do {
          num1 = random.nextInt(19);
          num2 = random.nextInt(19);
        } while (num1 + num2 > 18);
        correctAnswer = num1 + num2;
      } else if (dropdownValue == 'Sum of 20') {
        do {
          num1 = random.nextInt(21);
          num2 = random.nextInt(21);
        } while (num1 + num2 > 20);
        correctAnswer = num1 + num2;
      } else if (dropdownValue == 'Sum of 22') {
        do {
          num1 = random.nextInt(23);
          num2 = random.nextInt(23);
        } while (num1 + num2 > 22);
        correctAnswer = num1 + num2;
      } else if (dropdownValue == 'Sum of 24') {
        do {
          num1 = random.nextInt(25);
          num2 = random.nextInt(25);
        } while (num1 + num2 > 24);
        correctAnswer = num1 + num2;
      } else if (dropdownValue == 'Sum of 26') {
        do {
          num1 = random.nextInt(27);
          num2 = random.nextInt(27);
        } while (num1 + num2 > 26);
        correctAnswer = num1 + num2;
      } else if (dropdownValue == 'Sum of 50') {
        num1 = random.nextInt(51);
        num2 = random.nextInt(51);
        correctAnswer = num1 + num2;
      }
    } else if (operation == Operation.addition_B) {
      if (dropdownValue == 'Upto 5') {
        num1 = random.nextInt(6);
        num2 = random.nextInt(6);
        correctAnswer = num1 + num2;
      } else if (dropdownValue == 'Upto 10') {
        num1 = random.nextInt(11);
        num2 = random.nextInt(11);
        correctAnswer = num1 + num2;
      } else if (dropdownValue == 'Upto 15') {
        num1 = random.nextInt(16);
        num2 = random.nextInt(16);
        correctAnswer = num1 + num2;
      } else if (dropdownValue == 'Upto 20') {
        num1 = random.nextInt(21);
        num2 = random.nextInt(21);
        correctAnswer = num1 + num2;
      }
    } else if (operation == Operation.subtraction_A) {
      // Handle subtractionA logic
      if (dropdownValue.startsWith('Upto')) {
        int maxLimit = int.parse(dropdownValue.split(' ')[1]);
        num1 = random.nextInt(maxLimit + 1);
        num2 = random.nextInt(num1 + 1);
        correctAnswer = num1 - num2;
      }
    } else if (operation == Operation.subtraction_B) {
      // Handle subtractionB logic based on the difference
      if (dropdownValue == 'Less than 20') {
        num1 = random.nextInt(20) + 20;
        num2 = random.nextInt(num1);
        correctAnswer = num1 - num2;
      } else if (dropdownValue == 'Less than 40') {
        num1 = random.nextInt(40) + 40;
        num2 = random.nextInt(num1);
        correctAnswer = num1 - num2;
      } else if (dropdownValue == 'Less than 60') {
        num1 = random.nextInt(60) + 60;
        num2 = random.nextInt(num1);
        correctAnswer = num1 - num2;
      } else if (dropdownValue == 'Less than 80') {
        num1 = random.nextInt(80) + 80;
        num2 = random.nextInt(num1);
        correctAnswer = num1 - num2;
      } else if (dropdownValue == 'Less than 100') {
        num1 = random.nextInt(100) + 100;
        num2 = random.nextInt(num1);
        correctAnswer = num1 - num2;
      }
    } else if (operation == Operation.multiplication_C) {
      num1 = random.nextInt(10) + 1;
      num2 = rangeLimit;
      correctAnswer = num1 * num2;
    } else if (operation == Operation.division_C) {
      num2 = random.nextInt(10) + 1; // num2 should be between 1 and rangeLimit
      correctAnswer = random.nextInt(10) + 1; // correctAnswer should be between 1 and rangeLimit
      num1 = num2 * correctAnswer; // num1 is a multiple of num2
    } else if (operation == Operation.division_D) {
      // Handle divisionD logic based on the dropdown options
      num2 = random.nextInt(5) + 1; // Randomly choose divisor
      correctAnswer = random.nextInt(10) + 1; // Random correct answer
      num1 = num2 * correctAnswer; // num1 should be a multiple of num2
    }

    return [num1, num2, correctAnswer];
  }

  int generateRandomNumber() {
    final random = Random();
    return random.nextInt(100) + 1; // Generate random number between 1 and 100
  }
}