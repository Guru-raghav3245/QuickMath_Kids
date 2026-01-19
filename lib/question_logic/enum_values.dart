enum Operation {
  additionBeginner,
  additionIntermediate,
  additionAdvanced,
  subtractionBeginner,
  subtractionIntermediate,
  subtractionAdvanced,
  multiplicationBeginner,
  multiplicationIntermediate,
  multiplicationAdvanced,
  divisionBeginner,
  divisionIntermediate,
  divisionAdvanced,
  lcmBeginner,
  lcmIntermediate,
  lcmAdvanced,
  gcfBeginner,
  gcfIntermediate,
  gcfAdvanced,
}

enum Range {
  // Addition: Beginner
  additionBeginner1to5,
  additionBeginner6to10,
  additionBeginnerMixed1to10,
  additionBeginnerPlus1,
  additionBeginnerPlus2,
  additionBeginnerPlus3,
  additionBeginnerPlus4,
  additionBeginnerPlus5,

  // Addition: Intermediate
  additionIntermediate10to20,
  additionIntermediate20to30,
  additionIntermediate30to40,
  additionIntermediate40to50,
  additionIntermediateMixed10to50,
  additionIntermediatePlus6,
  additionIntermediatePlus7,
  additionIntermediatePlus8,
  additionIntermediatePlus9,
  additionIntermediatePlus10,

  // Addition: Advanced
  additionAdvanced50to100,
  additionAdvanced100to150,
  additionAdvanced150to200,
  additionAdvanced100to200,
  additionAdvancedMixed50to200,
  additionAdvancedMixed1to200,

  // Subtraction: Beginner
  subtractionBeginner1to10,
  subtractionBeginner10to20,
  subtractionBeginnerMixed1to20,
  subtractionBeginnerMinus1,
  subtractionBeginnerMinus2,
  subtractionBeginnerMinus3,
  subtractionBeginnerMinus4,
  subtractionBeginnerMinus5,

  // Subtraction: Intermediate
  subtractionIntermediate20to30,
  subtractionIntermediate30to40,
  subtractionIntermediate40to50,
  subtractionIntermediateMixed20to50,
  subtractionIntermediateMinus6,
  subtractionIntermediateMinus7,
  subtractionIntermediateMinus8,
  subtractionIntermediateMinus9,
  subtractionIntermediateMinus10,

  // Subtraction: Advanced
  subtractionAdvanced50to100,
  subtractionAdvanced100to150,
  subtractionAdvanced150to200,
  subtractionAdvancedMixed50to200,
  subtractionAdvancedMixed1to200,

  // Multiplication: Beginner
  multiplicationBeginnerX2,
  multiplicationBeginnerX3,
  multiplicationBeginnerX4,
  multiplicationBeginnerX5,
  multiplicationBeginnerMixedX2toX5,

  // Multiplication: Intermediate
  multiplicationIntermediateX6,
  multiplicationIntermediateX7,
  multiplicationIntermediateX8,
  multiplicationIntermediateX9,
  multiplicationIntermediateMixedX6toX9,

  // Multiplication: Advanced
  multiplicationAdvancedX10,
  multiplicationAdvancedX11,
  multiplicationAdvancedX12,
  multiplicationAdvancedMixedX10toX12,
  multiplicationAdvancedMixedX2toX12,

  // Division: Beginner
  divisionBeginnerBy2,
  divisionBeginnerBy3,
  divisionBeginnerBy4,
  divisionBeginnerBy5,
  divisionBeginnerMixedBy2to5,

  // Division: Intermediate
  divisionIntermediateBy6,
  divisionIntermediateBy7,
  divisionIntermediateBy8,
  divisionIntermediateBy9,
  divisionIntermediateMixedBy6to9,

  // Division: Advanced
  divisionAdvancedMixedBy2to10,

  // LCM: Beginner
  lcmBeginnerUpto10,
  lcmBeginnerUpto20,
  lcmBeginnerMixedUpto20,

  // LCM: Intermediate
  lcmIntermediateUpto30,
  lcmIntermediateUpto40,
  lcmIntermediateUpto50,
  lcmIntermediateUpto60,
  lcmIntermediateMixedUpto60,

  // LCM: Advanced
  lcmAdvancedUpto70,
  lcmAdvancedUpto80,
  lcmAdvancedUpto90,
  lcmAdvancedUpto100,
  lcmAdvanced3NumbersUpto10,
  lcmAdvanced3NumbersUpto20,
  lcmAdvanced3NumbersUpto30,
  lcmAdvanced3NumbersUpto40,
  lcmAdvanced3NumbersUpto50,
  lcmAdvancedMixedUpto100,
  lcmAdvancedMixed3NumbersUpto50,

  // GCF: Beginner
  gcfBeginnerUpto10,
  gcfBeginnerUpto20,
  gcfBeginnerMixedUpto20,

  // GCF: Intermediate
  gcfIntermediateUpto30,
  gcfIntermediateUpto40,
  gcfIntermediateUpto50,
  gcfIntermediateUpto60,
  gcfIntermediateMixedUpto60,

  // GCF: Advanced
  gcfAdvancedUpto70,
  gcfAdvancedUpto80,
  gcfAdvancedUpto90,
  gcfAdvancedUpto100,
  gcfAdvancedMixedUpto100,
}

Range getDefaultRange(Operation operation) {
  switch (operation) {
    case Operation.additionBeginner:
      return Range.additionBeginner1to5;
    case Operation.additionIntermediate:
      return Range.additionIntermediate10to20;
    case Operation.additionAdvanced:
      return Range.additionAdvanced50to100;
    case Operation.subtractionBeginner:
      return Range.subtractionBeginner1to10;
    case Operation.subtractionIntermediate:
      return Range.subtractionIntermediate20to30;
    case Operation.subtractionAdvanced:
      return Range.subtractionAdvanced50to100;
    case Operation.multiplicationBeginner:
      return Range.multiplicationBeginnerX2;
    case Operation.multiplicationIntermediate:
      return Range.multiplicationIntermediateX6;
    case Operation.multiplicationAdvanced:
      return Range.multiplicationAdvancedX10;
    case Operation.divisionBeginner:
      return Range.divisionBeginnerBy2;
    case Operation.divisionIntermediate:
      return Range.divisionIntermediateBy6;
    case Operation.divisionAdvanced:
      return Range.divisionAdvancedMixedBy2to10;
    case Operation.lcmBeginner:
      return Range.lcmBeginnerUpto10;
    case Operation.lcmIntermediate:
      return Range.lcmIntermediateUpto30;
    case Operation.lcmAdvanced:
      return Range.lcmAdvancedUpto70;
    case Operation.gcfBeginner:
      return Range.gcfBeginnerUpto10;
    case Operation.gcfIntermediate:
      return Range.gcfIntermediateUpto30;
    case Operation.gcfAdvanced:
      return Range.gcfAdvancedUpto70;
  }
}

// Helper method to convert Range enum to display string
String getRangeDisplayName(Range range) {
  switch (range) {
    // Addition: Beginner
    case Range.additionBeginner1to5:
      return '1-5';
    case Range.additionBeginner6to10:
      return '6-10';
    case Range.additionBeginnerMixed1to10:
      return 'Mixed (1-10)';
    case Range.additionBeginnerPlus1:
      return '+1';
    case Range.additionBeginnerPlus2:
      return '+2';
    case Range.additionBeginnerPlus3:
      return '+3';
    case Range.additionBeginnerPlus4:
      return '+4';
    case Range.additionBeginnerPlus5:
      return '+5';

    // Addition: Intermediate
    case Range.additionIntermediate10to20:
      return '10-20';
    case Range.additionIntermediate20to30:
      return '20-30';
    case Range.additionIntermediate30to40:
      return '30-40';
    case Range.additionIntermediate40to50:
      return '40-50';
    case Range.additionIntermediateMixed10to50:
      return 'Mixed (10-50)';
    case Range.additionIntermediatePlus6:
      return '+6';
    case Range.additionIntermediatePlus7:
      return '+7';
    case Range.additionIntermediatePlus8:
      return '+8';
    case Range.additionIntermediatePlus9:
      return '+9';
    case Range.additionIntermediatePlus10:
      return '+10';

    // Addition: Advanced
    case Range.additionAdvanced50to100:
      return '50-100';
    case Range.additionAdvanced100to150:
      return '100-150';
    case Range.additionAdvanced150to200:
      return '150-200';
    case Range.additionAdvanced100to200:
      return '100-200';
    case Range.additionAdvancedMixed50to200:
      return 'Mixed (50-200)';
    case Range.additionAdvancedMixed1to200:
      return 'Mixed (1-200)';

    // Subtraction: Beginner
    case Range.subtractionBeginner1to10:
      return '1-10';
    case Range.subtractionBeginner10to20:
      return '10-20';
    case Range.subtractionBeginnerMixed1to20:
      return 'Mixed (1-20)';
    case Range.subtractionBeginnerMinus1:
      return '-1';
    case Range.subtractionBeginnerMinus2:
      return '-2';
    case Range.subtractionBeginnerMinus3:
      return '-3';
    case Range.subtractionBeginnerMinus4:
      return '-4';
    case Range.subtractionBeginnerMinus5:
      return '-5';

    // Subtraction: Intermediate
    case Range.subtractionIntermediate20to30:
      return '20-30';
    case Range.subtractionIntermediate30to40:
      return '30-40';
    case Range.subtractionIntermediate40to50:
      return '40-50';
    case Range.subtractionIntermediateMixed20to50:
      return 'Mixed (20-50)';
    case Range.subtractionIntermediateMinus6:
      return '-6';
    case Range.subtractionIntermediateMinus7:
      return '-7';
    case Range.subtractionIntermediateMinus8:
      return '-8';
    case Range.subtractionIntermediateMinus9:
      return '-9';
    case Range.subtractionIntermediateMinus10:
      return '-10';

    // Subtraction: Advanced
    case Range.subtractionAdvanced50to100:
      return '50-100';
    case Range.subtractionAdvanced100to150:
      return '100-150';
    case Range.subtractionAdvanced150to200:
      return '150-200';
    case Range.subtractionAdvancedMixed50to200:
      return 'Mixed (50-200)';
    case Range.subtractionAdvancedMixed1to200:
      return 'Mixed (1-200)';

    // Multiplication: Beginner
    case Range.multiplicationBeginnerX2:
      return 'x2';
    case Range.multiplicationBeginnerX3:
      return 'x3';
    case Range.multiplicationBeginnerX4:
      return 'x4';
    case Range.multiplicationBeginnerX5:
      return 'x5';
    case Range.multiplicationBeginnerMixedX2toX5:
      return 'Mixed (x2-x5)';
    // Multiplication: Intermediate
    case Range.multiplicationIntermediateX6:
      return 'x6';
    case Range.multiplicationIntermediateX7:
      return 'x7';
    case Range.multiplicationIntermediateX8:
      return 'x8';
    case Range.multiplicationIntermediateX9:
      return 'x9';
    case Range.multiplicationIntermediateMixedX6toX9:
      return 'Mixed (x6-x9)';
    // Multiplication: Advanced
    case Range.multiplicationAdvancedX10:
      return 'x10';
    case Range.multiplicationAdvancedX11:
      return 'x11';
    case Range.multiplicationAdvancedX12:
      return 'x12';
    case Range.multiplicationAdvancedMixedX10toX12:
      return 'Mixed (x10-x12)';
    case Range.multiplicationAdvancedMixedX2toX12:
      return 'Mixed (x2-x12)';
    // Division: Beginner
    case Range.divisionBeginnerBy2:
      return 'Divided by 2';
    case Range.divisionBeginnerBy3:
      return 'Divided by 3';
    case Range.divisionBeginnerBy4:
      return 'Divided by 4';
    case Range.divisionBeginnerBy5:
      return 'Divided by 5';
    case Range.divisionBeginnerMixedBy2to5:
      return 'Mixed (Divided by 2-5)';
    // Division: Intermediate
    case Range.divisionIntermediateBy6:
      return 'Divided by 6';
    case Range.divisionIntermediateBy7:
      return 'Divided by 7';
    case Range.divisionIntermediateBy8:
      return 'Divided by 8';
    case Range.divisionIntermediateBy9:
      return 'Divided by 9';
    case Range.divisionIntermediateMixedBy6to9:
      return 'Mixed (Divided by 6-9)';
    // Division: Advanced
    case Range.divisionAdvancedMixedBy2to10:
      return 'Mixed (Divided by 2-10, quotient 1-10)';
    // LCM: Beginner
    case Range.lcmBeginnerUpto10:
      return 'Up to 10';
    case Range.lcmBeginnerUpto20:
      return 'Up to 20';
    case Range.lcmBeginnerMixedUpto20:
      return 'Mixed (Up to 20)';
    // LCM: Intermediate
    case Range.lcmIntermediateUpto30:
      return 'Up to 30';
    case Range.lcmIntermediateUpto40:
      return 'Up to 40';
    case Range.lcmIntermediateUpto50:
      return 'Up to 50';
    case Range.lcmIntermediateUpto60:
      return 'Up to 60';
    case Range.lcmIntermediateMixedUpto60:
      return 'Mixed (Up to 60)';
    // LCM: Advanced
    case Range.lcmAdvancedUpto70:
      return 'Up to 70';
    case Range.lcmAdvancedUpto80:
      return 'Up to 80';
    case Range.lcmAdvancedUpto90:
      return 'Up to 90';
    case Range.lcmAdvancedUpto100:
      return 'Up to 100';
    case Range.lcmAdvanced3NumbersUpto10:
      return '3 numbers Up to 10';
    case Range.lcmAdvanced3NumbersUpto20:
      return '3 numbers Up to 20';
    case Range.lcmAdvanced3NumbersUpto30:
      return '3 numbers Up to 30';
    case Range.lcmAdvanced3NumbersUpto40:
      return '3 numbers Up to 40';
    case Range.lcmAdvanced3NumbersUpto50:
      return '3 numbers Up to 50';
    case Range.lcmAdvancedMixedUpto100:
      return 'Mixed (Up to 100)';
    case Range.lcmAdvancedMixed3NumbersUpto50:
      return 'Mixed (3 numbers Up to 50)';
    // GCF: Beginner
    case Range.gcfBeginnerUpto10:
      return 'Up to 10';
    case Range.gcfBeginnerUpto20:
      return 'Up to 20';
    case Range.gcfBeginnerMixedUpto20:
      return 'Mixed (Up to 20)';
    // GCF: Intermediate
    case Range.gcfIntermediateUpto30:
      return 'Up to 30';
    case Range.gcfIntermediateUpto40:
      return 'Up to 40';
    case Range.gcfIntermediateUpto50:
      return 'Up to 50';
    case Range.gcfIntermediateUpto60:
      return 'Up to 60';
    case Range.gcfIntermediateMixedUpto60:
      return 'Mixed (Up to 60)';
    // GCF: Advanced
    case Range.gcfAdvancedUpto70:
      return 'Up to 70';
    case Range.gcfAdvancedUpto80:
      return 'Up to 80';
    case Range.gcfAdvancedUpto90:
      return 'Up to 90';
    case Range.gcfAdvancedUpto100:
      return 'Up to 100';
    case Range.gcfAdvancedMixedUpto100:
      return 'Mixed (Up to 100)';
  }
}
