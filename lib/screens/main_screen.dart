import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'dashboard_screen.dart';
import 'expenses_screen.dart';
import 'savings_screen.dart';
import 'investments_screen.dart';
import 'budget_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ExpensesScreen(),
    SavingsScreen(),
    InvestmentsScreen(),
    BudgetScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              backgroundColor: Colors.transparent,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Expenses'),
                BottomNavigationBarItem(icon: Icon(Icons.savings_rounded), label: 'Savings'),
                BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded), label: 'Invest'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet_rounded), label: 'Budget'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
