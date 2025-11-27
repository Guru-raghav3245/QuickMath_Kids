import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:QuickMath_Kids/screens/home_screen/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';
import 'package:QuickMath_Kids/services/billing_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();

  // Pre-initialize BillingService to start loading cached status immediately
  container.read(billingServiceProvider);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(UncontrolledProviderScope(container: container, child: MyApp()));
  });
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Wait for billing service to initialize
      final billingService = ref.read(billingServiceProvider);

      // Wait for billing service to be ready with timeout
      int attempts = 0;
      while (!billingService.isInitialized && attempts < 50) {
        // 5 second timeout
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (mounted) {
        setState(() {
          _initialized = true;
        });

        // Use a small delay to ensure the UI updates before navigation
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const StartScreen(),
            ),
          );
        }
      }
    } catch (e) {
      // If anything fails, still navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const StartScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(darkModeProvider);
    final theme = AppTheme.getTheme(ref, isDarkMode, context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use a fallback if the image fails to load
            _buildLogo(theme),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _initialized ? 'Almost ready...' : 'Loading QuickMath...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Image.asset(
      'assets/QuickMath_Kids_logo.png',
      height: 120,
      width: 120,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image fails to load
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.calculate,
            size: 60,
            color: theme.colorScheme.primary,
          ),
        );
      },
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(ref, false, context),
      darkTheme: AppTheme.getTheme(ref, true, context),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
