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

  Color _getDifficultyColor(Operation operation) {
    if (operation.name.contains('Beginner')) {
      return Colors.green;
    } else if (operation.name.contains('Intermediate')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  void _showGridSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OperationGridSheet(
        selectedOperation: selectedOperation,
        onSelect: (op) {
          onChanged(op);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    final displayName = _getDisplayName(selectedOperation);
    final operationName = displayName.split(':')[0];
    final difficultyName = displayName.split(':')[1].trim();
    final difficultyColor = _getDifficultyColor(selectedOperation);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: InkWell(
        onTap: () => _showGridSheet(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: isTablet ? 65 : 55,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 18),
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
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: difficultyColor.withOpacity(0.3)),
                ),
                child: Icon(
                  _getOperationIcon(selectedOperation),
                  size: 18,
                  color: difficultyColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      operationName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 14,
                        color: theme.colorScheme.onSurface,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      difficultyName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: isTablet ? 13 : 12,
                        color: difficultyColor,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: theme.colorScheme.primary,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OperationGridSheet extends StatelessWidget {
  final Operation selectedOperation;
  final ValueChanged<Operation> onSelect;

  const _OperationGridSheet({
    required this.selectedOperation,
    required this.onSelect,
  });

  static const Map<String, List<Operation>> _operationGroups = {
    'Addition': [
      Operation.additionBeginner,
      Operation.additionIntermediate,
      Operation.additionAdvanced
    ],
    'Subtraction': [
      Operation.subtractionBeginner,
      Operation.subtractionIntermediate,
      Operation.subtractionAdvanced
    ],
    'Multiplication': [
      Operation.multiplicationBeginner,
      Operation.multiplicationIntermediate,
      Operation.multiplicationAdvanced
    ],
    'Division': [
      Operation.divisionBeginner,
      Operation.divisionIntermediate,
      Operation.divisionAdvanced
    ],
    'LCM': [
      Operation.lcmBeginner,
      Operation.lcmIntermediate,
      Operation.lcmAdvanced
    ],
    'GCF': [
      Operation.gcfBeginner,
      Operation.gcfIntermediate,
      Operation.gcfAdvanced
    ],
  };

  IconData _getGroupIcon(String group) {
    switch (group) {
      case 'Addition':
        return Icons.add_circle_outline;
      case 'Subtraction':
        return Icons.remove_circle_outline;
      case 'Multiplication':
        return Icons.cancel_outlined;
      case 'Division':
        return Icons.percent;
      case 'LCM':
        return Icons.filter_1;
      case 'GCF':
        return Icons.filter_center_focus;
      default:
        return Icons.functions;
    }
  }

  String _getSummary(Operation op) {
    switch (op) {
      // Addition
      case Operation.additionBeginner:
        return 'Ranges & +1 to +5';
      case Operation.additionIntermediate:
        return 'Ranges & +6 to +10';
      case Operation.additionAdvanced:
        return '50-200';
      // Subtraction
      case Operation.subtractionBeginner:
        return 'Ranges & -1 to -5';
      case Operation.subtractionIntermediate:
        return 'Ranges & -6 to -10';
      case Operation.subtractionAdvanced:
        return '50-200';
      // Multiplication
      case Operation.multiplicationBeginner:
        return 'x2-x5';
      case Operation.multiplicationIntermediate:
        return 'x6-x9';
      case Operation.multiplicationAdvanced:
        return 'x10-x12';
      // Division
      case Operation.divisionBeginner:
        return '÷2-÷5';
      case Operation.divisionIntermediate:
        return '÷6-÷9';
      case Operation.divisionAdvanced:
        return '÷2-÷10';
      // LCM
      case Operation.lcmBeginner:
        return 'Max 20';
      case Operation.lcmIntermediate:
        return 'Max 60';
      case Operation.lcmAdvanced:
        return 'Max 100';
      // GCF
      case Operation.gcfBeginner:
        return 'Max 20';
      case Operation.gcfIntermediate:
        return 'Max 60';
      case Operation.gcfAdvanced:
        return 'Max 100';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Select Operation',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
          // Grid Content
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _operationGroups.length,
              separatorBuilder: (context, index) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final groupName = _operationGroups.keys.elementAt(index);
                final operations = _operationGroups[groupName]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getGroupIcon(groupName),
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          groupName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: operations.asMap().entries.map((entry) {
                        final op = entry.value;
                        final isSelected = op == selectedOperation;
                        final difficultyIndex =
                            entry.key; // 0=Beg, 1=Int, 2=Adv

                        // Define colors based on difficulty
                        Color color;
                        String label;
                        if (difficultyIndex == 0) {
                          color = Colors.green;
                          label = 'Beginner';
                        } else if (difficultyIndex == 1) {
                          color = Colors.orange;
                          label = 'Intermediate';
                        } else {
                          color = Colors.red;
                          label = 'Advanced';
                        }

                        // Short summary mapping
                        String summary = _getSummary(op);

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: difficultyIndex == 0 ? 0 : 6,
                                right: difficultyIndex == 2 ? 0 : 6),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => onSelect(op),
                                borderRadius: BorderRadius.circular(10),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? color
                                        : color.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? color
                                          : color.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        label,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isSelected ? Colors.white : color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        summary,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.9)
                                              : color.withOpacity(0.8),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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
    // Add specific number ranges to paid list if desired, e.g.:
    // Range.additionIntermediatePlus10,
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
            Icon(Icons.workspace_premium_rounded,
                color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Premium feature unlocked with subscription',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14, // Increased font size
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
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4), // Increased padding
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
          Icon(Icons.workspace_premium_rounded,
              size: 12, color: Colors.white), // Larger icon
          const SizedBox(width: 4),
          Text(
            'Premium',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 10, // Increased font size
              color: Colors.white,
              height: 1.0,
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
              Icon(Icons.linear_scale_rounded,
                  size: 20, color: theme.colorScheme.primary), // Larger icon
              const SizedBox(width: 12),
              Text(
                'Select a range',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 17 : 15, // Increased font size
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
              padding:
                  const EdgeInsets.symmetric(vertical: 8), // Increased padding
              child: Row(
                children: [
                  Container(
                    width: 36, // Larger
                    height: 36,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.grey.withOpacity(0.1)
                          : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLocked
                            ? Colors.grey.withOpacity(0.3)
                            : theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_outline : Icons.psychology_outlined,
                      size: 18, // Larger icon
                      color: isLocked ? Colors.grey : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          getRangeDisplayName(range),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: isTablet ? 15 : 13, // Increased font size
                            color: isLocked
                                ? theme.colorScheme.onSurface.withOpacity(0.4)
                                : theme.colorScheme.onSurface,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (isLocked) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Premium feature',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 11, // Increased font size
                              color: Colors.orange,
                              height: 1.0,
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
          height: isTablet ? 65 : 55, // Increased height
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 18),
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
          iconSize: 26,
          iconEnabledColor: theme.colorScheme.primary,
          iconDisabledColor: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: MediaQuery.of(context).size.height * 0.35,
          width: MediaQuery.of(context).size.width - 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
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
          height: 56, // Increased height
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 18 : 14),
        ),
        underline: const SizedBox(),
      ),
    );
  }
}
