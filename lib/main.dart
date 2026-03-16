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
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const MainScreen(),
      ),
    );
  }
}
