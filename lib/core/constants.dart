import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFF9800);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color income = Color(0xFF2E7D32);
  static const Color expense = Color(0xFFE53935);
}

class AppCategories {
  static const List<Map<String, dynamic>> list = [
    {'name': 'Food & Dining', 'icon': Icons.restaurant, 'color': Color(0xFFFF7043)},
    {'name': 'Transportation', 'icon': Icons.directions_car, 'color': Color(0xFF1E88E5)},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Color(0xFFEC407A)},
    {'name': 'Bills & Utilities', 'icon': Icons.receipt_long, 'color': Color(0xFFEF5350)},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Color(0xFF7E57C2)},
    {'name': 'Health & Medical', 'icon': Icons.local_hospital, 'color': Color(0xFF26A69A)},
    {'name': 'Education', 'icon': Icons.school, 'color': Color(0xFF29B6F6)},
    {'name': 'Personal Care', 'icon': Icons.face, 'color': Color(0xFFFFCA28)},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Color(0xFF26C6DA)},
    {'name': 'Others', 'icon': Icons.more_horiz, 'color': Color(0xFF78909C)},
  ];

  static Color getColor(String category) {
    final cat = list.firstWhere(
      (c) => c['name'] == category,
      orElse: () => list.last,
    );
    return cat['color'] as Color;
  }

  static IconData getIcon(String category) {
    final cat = list.firstWhere(
      (c) => c['name'] == category,
      orElse: () => list.last,
    );
    return cat['icon'] as IconData;
  }

  static List<String> get names => list.map((c) => c['name'] as String).toList();
}

class InvestmentTypes {
  static const List<String> list = [
    'Stocks',
    'Cryptocurrency',
    'Bonds',
    'Mutual Funds',
    'Real Estate',
    'ETF',
    'Others',
  ];
}

const String currencySymbol = '₱';
const String appName = 'PesoTrack';
