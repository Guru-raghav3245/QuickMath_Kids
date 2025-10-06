import 'package:QuickMath_Kids/screens/notifications_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:QuickMath_Kids/screens/support_screen.dart';
import 'package:QuickMath_Kids/screens/settings_screen.dart';
import 'package:QuickMath_Kids/screens/faq/faq_screen.dart';
import 'package:QuickMath_Kids/screens/how_to_use_screen.dart';
import 'package:QuickMath_Kids/screens/wrong_answer_screen.dart';
import 'package:QuickMath_Kids/screens/quiz_history_screen.dart';
import 'package:QuickMath_Kids/services/billing_service.dart';
import 'package:QuickMath_Kids/screens/purchase_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:QuickMath_Kids/main.dart';

class AppDrawer extends StatelessWidget {
  final BillingService billingService;
  final bool isDarkMode;
  final Function(bool) toggleDarkMode;

  const AppDrawer({
    required this.billingService,
    required this.isDarkMode,
    required this.toggleDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPremium = billingService.isPremium;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calculate,
                    size: 50,
                    color: theme.colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'QuickMath Kids',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.help_outline,
              iconColor: Colors.grey,
              title: 'FAQ',
              onTap: () => _navigateTo(context, FAQScreen()),
              backgroundColor: theme.colorScheme.surface,
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.info_outline,
              iconColor: Colors.grey,
              title: 'How to use?',
              onTap: () => _navigateTo(context, HowToUseScreen()),
              backgroundColor: theme.colorScheme.surface,
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.notifications_none,
              iconColor: Colors.grey,
              title: 'Notifications',
              onTap: () => _navigateTo(context, NotificationDemo()),
              backgroundColor: theme.colorScheme.surface,
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.settings,
              title: 'Settings',
              isPremiumRequired: !isPremium,
              onTap: () => _navigateTo(context,
                  isPremium ? const SettingsScreen() : const PurchaseScreen()),
              backgroundColor: theme.colorScheme.surface,
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.history,
              title: 'Wrong Answers History',
              isPremiumRequired: !isPremium,
              onTap: () => _navigateTo(context,
                  isPremium ? WrongAnswersScreen() : const PurchaseScreen()),
              backgroundColor: theme.colorScheme.surface,
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.history_toggle_off,
              title: 'Quiz History',
              isPremiumRequired: !isPremium,
              onTap: () => _navigateTo(context,
                  isPremium ? QuizHistoryScreen() : const PurchaseScreen()),
              backgroundColor: theme.colorScheme.surface,
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.support_agent,
              title: 'Get Support',
              onTap: () => _navigateTo(context, SupportScreen()),
              backgroundColor: theme.colorScheme.error.withOpacity(0.2),
              iconColor: theme.colorScheme.error,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              borderColor: theme.colorScheme.error,
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.star,
              title: 'Purchase Premium',
              onTap: () => _navigateTo(context, const PurchaseScreen()),
              backgroundColor: Colors.amber.withOpacity(0.2),
              iconColor: Colors.amber[800],
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              borderColor: Colors.amber[800],
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.3),
                  Colors.amber.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            // In the SwitchListTile part, update to:
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Consumer(
                builder: (context, ref, child) {
                  final isDarkMode = ref.watch(darkModeProvider);
                  return SwitchListTile(
                    title: Text(
                      "Dark Mode",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: isDarkMode,
                    onChanged: (value) {
                      ref.read(darkModeProvider.notifier).toggleDarkMode(value);
                    },
                    activeColor: theme.colorScheme.primary,
                    thumbColor:
                        WidgetStateProperty.all(theme.colorScheme.onPrimary),
                    trackColor: WidgetStateProperty.resolveWith((states) =>
                        states.contains(WidgetState.selected)
                            ? theme.colorScheme.primary.withOpacity(0.5)
                            : theme.colorScheme.surface),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isPremiumRequired = false,
    Color? backgroundColor,
    Color? iconColor,
    Color? borderColor,
    TextStyle? textStyle,
    Gradient? gradient,
  }) {
    final theme = Theme.of(context);
    final defaultIconColor =
        isPremiumRequired ? Colors.grey : theme.iconTheme.color;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        color:
            gradient == null ? backgroundColor ?? theme.cardTheme.color : null,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1.5)
            : isPremiumRequired
                ? Border.all(
                    color: theme.colorScheme.error.withOpacity(0.5), width: 1.5)
                : Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: theme.colorScheme.primary.withOpacity(0.3),
        highlightColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (iconColor ??
                          defaultIconColor ??
                          theme.colorScheme.primary)
                      .withOpacity(0.1),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? defaultIconColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.merge(textStyle).copyWith(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                ),
              ),
              if (isPremiumRequired)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.error.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
