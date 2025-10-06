import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:QuickMath_Kids/question_logic/enum_values.dart';
import 'package:QuickMath_Kids/services/billing_service.dart';
import 'package:QuickMath_Kids/screens/purchase_screen.dart';

class OperationDropdown extends ConsumerWidget {
  final Operation selectedOperation;
  final ValueChanged<Operation?> onChanged;

  const OperationDropdown({
    required this.selectedOperation,
    required this.onChanged,
    super.key,
  });

  String _getDisplayName(Operation operation) {
    switch (operation) {
      case Operation.additionBeginner:
        return 'Addition: Beginner';
      case Operation.additionIntermediate:
        return 'Addition: Intermediate';
      case Operation.additionAdvanced:
        return 'Addition: Advanced';
      case Operation.subtractionBeginner:
        return 'Subtraction: Beginner';
      case Operation.subtractionIntermediate:
        return 'Subtraction: Intermediate';
      case Operation.subtractionAdvanced:
        return 'Subtraction: Advanced';
      case Operation.multiplicationBeginner:
        return 'Multiplication: Beginner';
      case Operation.multiplicationIntermediate:
        return 'Multiplication: Intermediate';
      case Operation.multiplicationAdvanced:
        return 'Multiplication: Advanced';
      case Operation.divisionBeginner:
        return 'Division: Beginner';
      case Operation.divisionIntermediate:
        return 'Division: Intermediate';
      case Operation.divisionAdvanced:
        return 'Division: Advanced';
      case Operation.lcmBeginner:
        return 'LCM: Beginner';
      case Operation.lcmIntermediate:
        return 'LCM: Intermediate';
      case Operation.lcmAdvanced:
        return 'LCM: Advanced';
      case Operation.gcfBeginner:
        return 'GCF: Beginner';
      case Operation.gcfIntermediate:
        return 'GCF: Intermediate';
      case Operation.gcfAdvanced:
        return 'GCF: Advanced';
    }
  }

  IconData _getOperationIcon(Operation operation) {
    if (operation.name.contains('addition')) return Icons.add;
    if (operation.name.contains('subtraction')) return Icons.remove;
    if (operation.name.contains('multiplication')) return Icons.close;
    if (operation.name.contains('division')) return Icons.percent;
    if (operation.name.contains('lcm')) return Icons.filter_1;
    if (operation.name.contains('gcf')) return Icons.filter_center_focus;
    return Icons.functions;
  }

  Color _getDifficultyColor(Operation operation, ThemeData theme) {
    if (operation.name.contains('Beginner')) {
      return Colors.green;
    } else if (operation.name.contains('Intermediate')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: DropdownButton2<Operation>(
        value: selectedOperation,
        hint: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.tune_rounded, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Select an operation',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 16 : 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        items: Operation.values.map((operation) {
          final difficultyColor = _getDifficultyColor(operation, theme);
          final displayName = _getDisplayName(operation);
          final operationName = displayName.split(':')[0];
          final difficultyName = displayName.split(':')[1].trim();
          
          return DropdownMenuItem<Operation>(
            value: operation,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4), // Reduced padding
              child: Row(
                children: [
                  Container(
                    width: 32, // Slightly smaller
                    height: 32,
                    decoration: BoxDecoration(
                      color: difficultyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: difficultyColor.withOpacity(0.3)),
                    ),
                    child: Icon(
                      _getOperationIcon(operation),
                      size: 16, // Smaller icon
                      color: difficultyColor,
                    ),
                  ),
                  const SizedBox(width: 10), // Reduced spacing
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Important: prevent overflow
                      children: [
                        Text(
                          operationName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 14 : 12, // Smaller font
                            color: theme.colorScheme.onSurface,
                            height: 1.2, // Tighter line height
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1), // Minimal spacing
                        Text(
                          difficultyName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: isTablet ? 11 : 10, // Smaller font
                            color: difficultyColor,
                            height: 1.2, // Tighter line height
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Smaller padding
                    decoration: BoxDecoration(
                      color: difficultyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      operation.name.contains('Beginner') ? 'Easy' : 
                      operation.name.contains('Intermediate') ? 'Medium' : 'Hard',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 9, // Smaller font
                        color: difficultyColor,
                        height: 1.1, // Tighter line height
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        buttonStyleData: ButtonStyleData(
          height: isTablet ? 60 : 50, // Slightly reduced height
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceVariant,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          elevation: 0,
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: theme.colorScheme.primary,
          ),
          iconSize: 24, // Slightly smaller
          iconEnabledColor: theme.colorScheme.primary,
          iconDisabledColor: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 400,
          width: MediaQuery.of(context).size.width - 80,
          padding: const EdgeInsets.symmetric(vertical: 6), // Reduced padding
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          offset: const Offset(0, -6),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(4),
            thumbVisibility: MaterialStateProperty.all(true),
            thumbColor: MaterialStateProperty.all(
              theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 48, // Reduced height to prevent overflow
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
        ),
        underline: const SizedBox(),
      ),
    );
  }
}

class RangeDropdown extends ConsumerWidget {
  final Range selectedRange;
  final List<DropdownMenuItem<Range>> items;
  final ValueChanged<Range?> onChanged;

  const RangeDropdown({
    required this.selectedRange,
    required this.items,
    required this.onChanged,
    super.key,
  });

  static const Set<Range> _paidRanges = {
    Range.additionBeginnerMixed1to10,
    Range.additionIntermediateMixed10to50,
    Range.additionAdvancedMixed1to200,
    Range.subtractionBeginnerMixed1to20,
    Range.subtractionIntermediate40to50,
    Range.subtractionIntermediateMixed20to50,
    Range.subtractionAdvancedMixed50to200,
    Range.subtractionAdvancedMixed1to200,
    Range.multiplicationBeginnerX5,
    Range.multiplicationBeginnerMixedX2toX5,
    Range.multiplicationIntermediateX9,
    Range.multiplicationIntermediateMixedX6toX9,
    Range.multiplicationAdvancedX12,
    Range.multiplicationAdvancedMixedX10toX12,
    Range.multiplicationAdvancedMixedX2toX12,
    Range.divisionBeginnerBy5,
    Range.divisionBeginnerMixedBy2to5,
    Range.divisionIntermediateBy9,
    Range.divisionIntermediateMixedBy6to9,
    Range.divisionAdvancedMixedBy2to10,
    Range.lcmBeginnerUpto20,
    Range.lcmBeginnerMixedUpto20,
    Range.lcmIntermediateUpto60,
    Range.lcmIntermediateMixedUpto60,
    Range.lcmAdvanced3NumbersUpto50,
    Range.lcmAdvancedMixedUpto100,
    Range.lcmAdvancedMixed3NumbersUpto50,
    Range.gcfBeginnerMixedUpto20,
    Range.gcfIntermediateUpto60,
    Range.gcfIntermediateMixedUpto60,
    Range.gcfAdvancedUpto100,
    Range.gcfAdvancedMixedUpto100,
  };

  void _navigateToPurchaseScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PurchaseScreen()),
    );
  }

  void _showPremiumSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Premium feature unlocked with subscription',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Unlock',
          textColor: Colors.white,
          onPressed: () => _navigateToPurchaseScreen(context),
        ),
        backgroundColor: Colors.deepPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Smaller
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            'Premium',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 8, // Smaller font
              color: Colors.white,
              height: 1.1, // Tighter line height
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final billingService = ref.watch(billingServiceProvider);
    final isPremium = billingService.isPremium;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: DropdownButton2<Range>(
        value: selectedRange,
        hint: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.linear_scale_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'Select a range',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 15 : 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        items: items.map((item) {
          final range = item.value!;
          final isLocked = _paidRanges.contains(range) && !isPremium;

          return DropdownMenuItem<Range>(
            value: range,
            enabled: !isLocked,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4), // Reduced padding
              child: Row(
                children: [
                  Container(
                    width: 30, // Smaller
                    height: 30,
                    decoration: BoxDecoration(
                      color: isLocked 
                          ? Colors.grey.withOpacity(0.1)
                          : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isLocked 
                            ? Colors.grey.withOpacity(0.3)
                            : theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline : Icons.psychology_outlined,
                      size: 14, // Smaller icon
                      color: isLocked ? Colors.grey : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Prevent overflow
                      children: [
                        Text(
                          getRangeDisplayName(range),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: isTablet ? 13 : 11, // Smaller font
                            color: isLocked
                                ? theme.colorScheme.onSurface.withOpacity(0.4)
                                : theme.colorScheme.onSurface,
                            height: 1.2, // Tighter line height
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isLocked) ...[
                          const SizedBox(height: 1),
                          Text(
                            'Premium feature',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 9, // Smaller font
                              color: Colors.orange,
                              height: 1.1, // Tighter line height
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isLocked) _buildPremiumBadge(),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (Range? newValue) {
          if (newValue == null) return;
          if (_paidRanges.contains(newValue) && !isPremium) {
            _showPremiumSnackBar(context);
            return;
          }
          onChanged(newValue);
        },
        isExpanded: true,
        buttonStyleData: ButtonStyleData(
          height: isTablet ? 60 : 50, // Reduced height
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surfaceVariant,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          elevation: 0,
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: theme.colorScheme.primary,
          ),
          iconSize: 24,
          iconEnabledColor: theme.colorScheme.primary,
          iconDisabledColor: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 380,
          width: MediaQuery.of(context).size.width - 80,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          offset: const Offset(0, -6),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(4),
            thumbVisibility: MaterialStateProperty.all(true),
            thumbColor: MaterialStateProperty.all(
              theme.colorScheme.primary.withOpacity(0.5),
            ),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 46, // Reduced height
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
        ),
        underline: const SizedBox(),
      ),
    );
  }
}