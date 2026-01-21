import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/billing_service.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen>
    with WidgetsBindingObserver {
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('PurchaseScreen: App resumed, refreshing premium status...');
      ref.read(billingServiceProvider).restorePurchase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final billingService = ref.watch(billingServiceProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Unlock Premium Features',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Container(
        color: theme.colorScheme.background,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 800 : 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star,
                                  color: Colors.amber[400], size: 36),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Go Premium!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Unlock powerful tools to boost your math skills with a one-time purchase.',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // NEW: Unlimited Quizzes
                          _buildFeatureTile(
                            context,
                            icon: Icons.all_inclusive,
                            title: 'Unlimited Daily Quizzes',
                            description:
                                'Practice as much as you want! Free users are limited to 3 quizzes per day.',
                          ),
                          _buildFeatureTile(
                            context,
                            icon: Icons.history,
                            title: 'Wrong Answers History',
                            description:
                                'Review and practice questions you got wrong to improve your skills.',
                          ),
                          _buildFeatureTile(
                            context,
                            icon: Icons.history_toggle_off,
                            title: 'Quiz History',
                            description:
                                'Track your past quiz performances to monitor progress.',
                          ),
                          // NEW: Custom Time Limits
                          _buildFeatureTile(
                            context,
                            icon: Icons.timer,
                            title: 'Custom Time Limits',
                            description:
                                'Set your own practice duration or choose "No Time Limit" mode.',
                          ),
                          _buildFeatureTile(
                            context,
                            icon: Icons.settings,
                            title: 'Advanced Settings',
                            description:
                                'Customize your learning experience with voice settings.',
                          ),
                          _buildFeatureTile(
                            context,
                            icon: Icons.lock_open,
                            title: 'Exclusive Practice Ranges',
                            description:
                                'Access advanced and mixed number ranges for all operations.',
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Icon(Icons.monetization_on,
                                  color: theme.colorScheme.primary, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '₹300 - One-Time Payment',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.primary,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Non-refundable purchase. Proceed with confidence!',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.error,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _isPurchasing
                        ? CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation(
                                theme.colorScheme.primary),
                          )
                        : billingService.isPremium
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.check_circle,
                                      color: Colors.green, size: 28),
                                  SizedBox(width: 12),
                                  Text(
                                    'You\'re Already Premium!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              )
                            : AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    setState(() {
                                      _isPurchasing = true;
                                    });
                                    await ref
                                        .read(billingServiceProvider.notifier)
                                        .restorePurchase();
                                    final success = await billingService
                                        .purchasePremium(context);
                                    setState(() {
                                      _isPurchasing = false;
                                    });
                                    if (success) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Welcome to Premium!',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor:
                                              theme.colorScheme.primary,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  icon: const Icon(Icons.lock_open,
                                      color: Colors.white, size: 24),
                                  label: Text(
                                    'Unlock for ₹300',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                ),
                              ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _showPromoDialog(context),
                      icon:
                          const Icon(Icons.card_giftcard, color: Colors.white),
                      label: Text(
                        'Redeem Promo Code',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.cancel,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      label: Text(
                        'Not Now',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
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
  }

  Future<void> _showPromoDialog(BuildContext context) async {
    final TextEditingController codeController = TextEditingController();
    bool isRedeeming = false;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.card_giftcard,
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  // FIXED: Wrapped Text in Expanded to prevent overflow
                  Expanded(
                    child: Text(
                      'Redeem Promo Code',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter your Google Play promo code to unlock Premium for FREE!',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Promo Code (e.g. ABC123XYZ)',
                      prefixIcon:
                          Icon(Icons.vpn_key, color: theme.colorScheme.primary),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    autofocus: true,
                    autocorrect: false,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isRedeeming ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                        color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: isRedeeming
                      ? null
                      : () async {
                          final code = codeController.text.trim().toUpperCase();
                          if (code.isEmpty) return;

                          setDialogState(() => isRedeeming = true);

                          final redeemUrl = Uri.parse(
                              'https://play.google.com/redeem?code=$code');

                          if (await canLaunchUrl(redeemUrl)) {
                            await launchUrl(redeemUrl,
                                mode: LaunchMode.externalApplication);
                          } else {
                            await launchUrl(
                                Uri.parse('https://play.google.com/redeem'),
                                mode: LaunchMode.externalApplication);
                          }

                          setDialogState(() => isRedeeming = false);
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✅ Code sent to Play Store!\nComplete redemption, then return to app.',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        },
                  icon: isRedeeming
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.redeem, size: 20),
                  label: Text(
                      isRedeeming ? 'Opening Play Store...' : 'Redeem Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
