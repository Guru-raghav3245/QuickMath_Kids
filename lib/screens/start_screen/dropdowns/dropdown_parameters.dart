import 'package:flutter/material.dart';
import 'package:QuickMath_Kids/question_logic/enum_values.dart';

List<DropdownMenuItem<Range>> getDropdownItems(Operation selectedOperation) {
  List<Range> ranges;
  switch (selectedOperation) {
    case Operation.additionBeginner:
      ranges = [
        Range.additionBeginner1to5,
        Range.additionBeginner6to10,
        Range.additionBeginnerMixed1to10,
      ];
      break;
    case Operation.additionIntermediate:
      ranges = [
        Range.additionIntermediate10to20,
        Range.additionIntermediate20to30,
        Range.additionIntermediate30to40,
        Range.additionIntermediate40to50,
        Range.additionIntermediateMixed10to50,
      ];
      break;
    case Operation.additionAdvanced:
      ranges = [
        Range.additionAdvanced50to100,
        Range.additionAdvanced100to150,
        Range.additionAdvanced150to200,
        Range.additionAdvanced100to200,
        Range.additionAdvancedMixed50to200,
        Range.additionAdvancedMixed1to200,
      ];
      break;
    case Operation.subtractionBeginner:
      ranges = [
        Range.subtractionBeginner1to10,
        Range.subtractionBeginner10to20,
        Range.subtractionBeginnerMixed1to20,
      ];
      break;
    case Operation.subtractionIntermediate:
      ranges = [
        Range.subtractionIntermediate20to30,
        Range.subtractionIntermediate30to40,
        Range.subtractionIntermediate40to50,
        Range.subtractionIntermediateMixed20to50,
      ];
      break;
    case Operation.subtractionAdvanced:
      ranges = [
        Range.subtractionAdvanced50to100,
        Range.subtractionAdvanced100to150,
        Range.subtractionAdvanced150to200,
        Range.subtractionAdvancedMixed50to200,
        Range.subtractionAdvancedMixed1to200,
      ];
      break;
    case Operation.multiplicationBeginner:
      ranges = [
        Range.multiplicationBeginnerX2,
        Range.multiplicationBeginnerX3,
        Range.multiplicationBeginnerX4,
        Range.multiplicationBeginnerX5,
        Range.multiplicationBeginnerMixedX2toX5,
      ];
      break;
    case Operation.multiplicationIntermediate:
      ranges = [
        Range.multiplicationIntermediateX6,
        Range.multiplicationIntermediateX7,
        Range.multiplicationIntermediateX8,
        Range.multiplicationIntermediateX9,
        Range.multiplicationIntermediateMixedX6toX9,
      ];
      break;
    case Operation.multiplicationAdvanced:
      ranges = [
        Range.multiplicationAdvancedX10,
        Range.multiplicationAdvancedX11,
        Range.multiplicationAdvancedX12,
        Range.multiplicationAdvancedMixedX10toX12,
        Range.multiplicationAdvancedMixedX2toX12,
      ];
      break;
    case Operation.divisionBeginner:
      ranges = [
        Range.divisionBeginnerBy2,
        Range.divisionBeginnerBy3,
        Range.divisionBeginnerBy4,
        Range.divisionBeginnerBy5,
        Range.divisionBeginnerMixedBy2to5,
      ];
      break;
    case Operation.divisionIntermediate:
      ranges = [
        Range.divisionIntermediateBy6,
        Range.divisionIntermediateBy7,
        Range.divisionIntermediateBy8,
        Range.divisionIntermediateBy9,
        Range.divisionIntermediateMixedBy6to9,
      ];
      break;
    case Operation.divisionAdvanced:
      ranges = [Range.divisionAdvancedMixedBy2to10];
      break;
    case Operation.lcmBeginner:
      ranges = [
        Range.lcmBeginnerUpto10,
        Range.lcmBeginnerUpto20,
        Range.lcmBeginnerMixedUpto20,
      ];
      break;
    case Operation.lcmIntermediate:
      ranges = [
        Range.lcmIntermediateUpto30,
        Range.lcmIntermediateUpto40,
        Range.lcmIntermediateUpto50,
        Range.lcmIntermediateUpto60,
        Range.lcmIntermediateMixedUpto60,
      ];
      break;
    case Operation.lcmAdvanced:
      ranges = [
        Range.lcmAdvancedUpto70,
        Range.lcmAdvancedUpto80,
        Range.lcmAdvancedUpto90,
        Range.lcmAdvancedUpto100,
        Range.lcmAdvanced3NumbersUpto10,
        Range.lcmAdvanced3NumbersUpto20,
        Range.lcmAdvanced3NumbersUpto30,
        Range.lcmAdvanced3NumbersUpto40,
        Range.lcmAdvanced3NumbersUpto50,
        Range.lcmAdvancedMixedUpto100,
        Range.lcmAdvancedMixed3NumbersUpto50,
      ];
      break;
    case Operation.gcfBeginner:
      ranges = [
        Range.gcfBeginnerUpto10,
        Range.gcfBeginnerUpto20,
        Range.gcfBeginnerMixedUpto20,
      ];
      break;
    case Operation.gcfIntermediate:
      ranges = [
        Range.gcfIntermediateUpto30,
        Range.gcfIntermediateUpto40,
        Range.gcfIntermediateUpto50,
        Range.gcfIntermediateUpto60,
        Range.gcfIntermediateMixedUpto60,
      ];
      break;
    case Operation.gcfAdvanced:
      ranges = [
        Range.gcfAdvancedUpto70,
        Range.gcfAdvancedUpto80,
        Range.gcfAdvancedUpto90,
        Range.gcfAdvancedUpto100,
        Range.gcfAdvancedMixedUpto100,
      ];
      break;
  }

  return ranges.map((range) {
    return DropdownMenuItem<Range>(
      value: range,
      child: Text(getRangeDisplayName(range)),
    );
  }).toList();
}
