import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:QuickMath_Kids/question_logic/question_generator.dart';
import 'package:QuickMath_Kids/screens/settings_screen/settings_screen.dart';
import 'package:QuickMath_Kids/screens/home_screen/dropdowns/dropdown_widgets.dart';
import 'package:QuickMath_Kids/screens/home_screen/dropdowns/dropdown_parameters.dart';
import 'package:QuickMath_Kids/screens/faq/faq_screen.dart';
import 'package:QuickMath_Kids/screens/how_to_use_screen.dart';
import 'package:QuickMath_Kids/wrong_answer_storing/wrong_answer_screen.dart';
import 'package:QuickMath_Kids/quiz_history/quiz_history_screen.dart';
import 'package:QuickMath_Kids/billing/billing_service.dart';
import 'package:QuickMath_Kids/billing/purchase_screen.dart';
import 'package:QuickMath_Kids/app_theme.dart';

class StartScreen extends ConsumerStatefulWidget {
  final Function(Operation, String, int?) switchToPracticeScreen;
  final VoidCallback switchToStartScreen;
  final Function(bool) toggleDarkMode;
  final bool isDarkMode;

  const StartScreen(
    this.switchToPracticeScreen,
    this.switchToStartScreen,
    this.toggleDarkMode, {
    required this.isDarkMode,
    super.key,
  });

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  Operation _selectedOperation = Operation.addition_2A;
  String _selectedRange = 'Upto +5';
  int? _selectedTimeLimit;
  int _selectedMinutes = 5;
  bool _noLimit = true;
  bool _isDarkMode = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _selectedTimeLimit = null;
  }

  @override
  void didUpdateWidget(StartScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      setState(() {
        _isDarkMode = widget.isDarkMode;
      });
    }
  }

  void _showTimeWheelPicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Set Time Limit', style: theme.textTheme.titleLarge),
                      Row(
                        children: [
                          Text('No Limit', style: theme.textTheme.bodyLarge),
                          Switch(
                            value: _noLimit,
                            onChanged: (value) {
                              setModalState(() {
                                _noLimit = value;
                              });
                            },
                            activeTrackColor: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!_noLimit)
                    SizedBox(
                      height: 150,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 50,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setModalState(() {
                            _selectedMinutes = index + 1;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            final minute = index + 1;
                            final isSelected = minute == _selectedMinutes;
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary.withOpacity(0.2)
                                      : Colors.transparent,
                                  border: isSelected
                                      ? Border.all(
                                          color: theme.colorScheme.primary,
                                          width: 2)
                                      : null,
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                ),
                                child: Text(
                                  '$minute minute${minute == 1 ? '' : 's'}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 20,
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                    fontWeight:
                                        isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: 60,
                        ),
                      ),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (_noLimit) {
                          _selectedTimeLimit = null;
                        } else {
                          _selectedTimeLimit = _selectedMinutes * 60;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Confirm'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

 @override
Widget build(BuildContext context) {
  final billingService = ref.watch(billingServiceProvider);
  final screenWidth = MediaQuery.of(context).size.width;
  final isTablet = screenWidth > 600;

  if (!billingService.isInitialized) {
    return Consumer(
      builder: (context, ref, child) {
        final theme = AppTheme.getTheme(ref, widget.isDarkMode, context);
        return Theme(
          data: theme,
          child: const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }

  return Consumer(
    builder: (context, ref, child) {
      final theme = AppTheme.getTheme(ref, widget.isDarkMode, context);
      return Theme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('QuickMath Kids'),
            actions: [
              IconButton(
                icon: _isRestoring
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.refresh),
                onPressed: _isRestoring
                    ? null
                    : () async {
                        setState(() {
                          _isRestoring = true;
                        });
                        final billingService = ref.read(billingServiceProvider);
                        await billingService.restorePurchase();
                        setState(() {
                          _isRestoring = false;
                        });
                        if (billingService.isPremium) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Premium status restored')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No premium purchase found')),
                          );
                        }
                      },
              ),
            ],
          ),
          drawer: _buildDrawer(context),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 700 : double.infinity), // Increased maxWidth for tablets
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 24 : 16), // More padding on tablets
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/QuickMath_Kids_logo.png',
                      width: isTablet ? 250 : 200, // Larger logo on tablets
                      height: isTablet ? 250 : 200,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Choose an Operation and Start Practicing",
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    OperationDropdown(
                      selectedOperation: _selectedOperation,
                      onChanged: (Operation? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedOperation = newValue;
                            _selectedRange = getDefaultRange(newValue);
                            if (!getDropdownItems(_selectedOperation)
                                .any((item) => item.value == _selectedRange)) {
                              _selectedRange =
                                  getDropdownItems(_selectedOperation).first.value!;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    RangeDropdown(
                      selectedRange: _selectedRange,
                      items: getDropdownItems(_selectedOperation),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedRange = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: InkWell(
                        onTap: () => _showTimeWheelPicker(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Session Time Limit',
                          ),
                          child: Text(
                            _selectedTimeLimit != null
                                ? '${_selectedTimeLimit! ~/ 60} minute${_selectedTimeLimit! ~/ 60 == 1 ? '' : 's'}'
                                : 'No time limit',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () {
                        widget.switchToPracticeScreen(
                            _selectedOperation, _selectedRange, _selectedTimeLimit);
                      },
                      label: const Text('Start Oral Practice'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: isTablet ? 24 : 18, // More padding on tablets
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final billingService = ref.read(billingServiceProvider);
                        await billingService.resetPremium();
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Premium access reset. You can purchase again.')),
                        );
                      },
                      child: const Text('Reset Premium'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: isTablet ? 24 : 18, // More padding on tablets
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildDrawer(BuildContext context) {
    final billingService = ref.watch(billingServiceProvider);
    final theme = Theme.of(context);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Text('QuickMath Kids',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: theme.colorScheme.onPrimary)),
          ),
          if (!billingService.isPremium)
            Container(
              color: theme.colorScheme.error,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Premium Required',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onError, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: !billingService.isPremium
                ? BoxDecoration(
                    border: Border.all(color: theme.colorScheme.error, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  )
                : null,
            child: ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                if (billingService.isPremium) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PurchaseScreen()),
                  );
                }
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('How to use?'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HowToUseScreen()),
              );
            },
          ),
          if (!billingService.isPremium)
            Container(
              color: theme.colorScheme.error,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Premium Required',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onError, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: !billingService.isPremium
                ? BoxDecoration(
                    border: Border.all(color: theme.colorScheme.error, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  )
                : null,
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Wrong Answers History'),
              onTap: () {
                Navigator.pop(context);
                if (billingService.isPremium) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WrongAnswersScreen(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PurchaseScreen()),
                  );
                }
              },
            ),
          ),
          if (!billingService.isPremium)
            Container(
              color: theme.colorScheme.error,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Premium Required',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onError, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: !billingService.isPremium
                ? BoxDecoration(
                    border: Border.all(color: theme.colorScheme.error, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  )
                : null,
            child: ListTile(
              leading: const Icon(Icons.history_toggle_off),
              title: const Text('Quiz History'),
              onTap: () {
                Navigator.pop(context);
                if (billingService.isPremium) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          QuizHistoryScreen(widget.switchToStartScreen),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PurchaseScreen()),
                  );
                }
              },
            ),
          ),
          if (!billingService.isPremium)
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Purchase Premium'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PurchaseScreen()),
                );
              },
            ),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: _isDarkMode,
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
                widget.toggleDarkMode(value);
              });
            },
          ),
        ],
      ),
    );
  }
}