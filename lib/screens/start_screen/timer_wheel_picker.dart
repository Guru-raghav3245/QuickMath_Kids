import 'dart:async';
import 'package:flutter/material.dart';
import 'package:QuickMath_Kids/screens/purchase_screen.dart';

class TimeWheelPicker extends StatefulWidget {
  final int initialIndex;
  final bool isPremium;
  final Function(int) onConfirm;
  final VoidCallback? onPremiumStatusChanged;

  const TimeWheelPicker({
    super.key,
    required this.initialIndex,
    required this.isPremium,
    required this.onConfirm,
    this.onPremiumStatusChanged,
  });

  @override
  _TimeWheelPickerState createState() => _TimeWheelPickerState();
}

class _TimeWheelPickerState extends State<TimeWheelPicker> {
  late int _selectedIndex;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _startInactivityTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  // Start or reset the inactivity timer
  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void didUpdateWidget(TimeWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPremium != widget.isPremium) {
      // Premium status changed - reset to free default if needed
      if (!widget.isPremium && _selectedIndex != 2) {
        setState(() {
          _selectedIndex = 2;
        });
      }
      widget.onPremiumStatusChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final freeTierDefaultIndex = 2; // 2 minutes is index 2

    return Container(
      height: 340,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Set Time Limit',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isPremium
                ? 'Choose any time limit'
                : 'Free users are limited to 2 minutes. Upgrade to Premium for more options!',
            style: TextStyle(
              fontSize: 14,
              color: widget.isPremium 
                  ? theme.colorScheme.onSurface.withOpacity(0.7)
                  : theme.colorScheme.error,
              fontStyle: widget.isPremium ? FontStyle.normal : FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: ListWheelScrollView.useDelegate(
              itemExtent: 50,
              diameterRatio: 1.5,
              onSelectedItemChanged: (index) {
                if (widget.isPremium) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
                _startInactivityTimer(); // Reset timer on scroll
              },
              controller:
                  FixedExtentScrollController(initialItem: _selectedIndex),
              childDelegate: ListWheelChildListDelegate(
                children: List.generate(
                  11,
                  (index) {
                    final isSelected = index == _selectedIndex;
                    final isLocked =
                        !widget.isPremium && index != freeTierDefaultIndex;
                    final displayText = index == 0
                        ? 'No Limit'
                        : '$index minute${index == 1 ? '' : 's'}';

                    return Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLocked) ...[
                              Icon(Icons.lock,
                                  size: 16, 
                                  color: theme.colorScheme.onSurface.withOpacity(0.5)),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              displayText,
                              style: TextStyle(
                                fontSize: 20,
                                color: isLocked
                                    ? theme.colorScheme.onSurface.withOpacity(0.5)
                                    : isSelected
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (isLocked) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.shade400,
                                      Colors.orange.shade600,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Premium',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _startInactivityTimer();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _startInactivityTimer(); // Reset timer on button press
                    if (!widget.isPremium && _selectedIndex != freeTierDefaultIndex) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: theme.colorScheme.onError,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Custom time limits are a Premium feature. Upgrade to unlock!',
                                  style: TextStyle(
                                    color: theme.colorScheme.onError,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: theme.colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                          elevation: 6,
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Upgrade',
                            textColor: Colors.white,
                            backgroundColor: theme.colorScheme.primary,
                            onPressed: () {
                              _startInactivityTimer(); // Reset timer on action press
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PurchaseScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                      return;
                    }

                    widget.onConfirm(_selectedIndex);
                    Navigator.pop(context);
                  },
                  child: const Text('Confirm'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}