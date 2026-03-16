import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'providers/expense_provider.dart';
import 'providers/savings_provider.dart';
import 'providers/investment_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/piggy_bank_provider.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PesoTrackApp());
}

class PesoTrackApp extends StatelessWidget {
  const PesoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()..load()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => InvestmentProvider()..load()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()..load()),
        ChangeNotifierProvider(create: (_) => PiggyBankProvider()..load()),
      ],
      child: MaterialApp(
        title: appName,
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
        builder: (context, child) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.bgStart, AppColors.bgMid, AppColors.bgEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              const _BackgroundBlobs(),
              child!,
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: _blob(AppColors.blob1, 380, 0.25),
          ),
          Positioned(
            bottom: 80,
            right: -80,
            child: _blob(AppColors.blob2, 300, 0.18),
          ),
          Positioned(
            top: 380,
            right: -40,
            child: _blob(AppColors.blob3, 220, 0.12),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }
}
