import 'package:flutter/material.dart';

class AppColors {
  // Primary palette (glassmorphism)
  static const Color primary = Color(0xFFA78BFA);      // Soft lavender purple
  static const Color primaryLight = Color(0xFFC4B5FD); // Light purple
  static const Color primaryDark = Color(0xFF7C5CBF);  // Deep purple
  static const Color accent = Color(0xFF00D4AA);        // Teal

  // Semantic colors
  static const Color error = Color(0xFFF87171);         // Soft red
  static const Color success = Color(0xFF4ADE80);       // Bright green
  static const Color warning = Color(0xFFFBBF24);       // Amber
  static const Color income = Color(0xFF4ADE80);        // Green
  static const Color expense = Color(0xFFF87171);       // Red

  // Text (on dark glass background)
  static const Color textPrimary = Color(0xFFFFFFFF);   // White
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white

  // Background gradient stops
  static const Color bgStart = Color(0xFF0F0C29);
  static const Color bgMid = Color(0xFF302B63);
  static const Color bgEnd = Color(0xFF24243E);

  // Glass surface
  static const Color background = Color(0xFF0F0C29);
  static const Color surface = Color(0x14FFFFFF);       // 8% white
  static const Color glassBg = Color(0x14FFFFFF);       // 8% white
  static const Color glassBorder = Color(0x26FFFFFF);   // 15% white

  // Decorative blobs
  static const Color blob1 = Color(0xFF6C63FF);         // Purple
  static const Color blob2 = Color(0xFF00D4AA);         // Teal
  static const Color blob3 = Color(0xFFFF6B9D);         // Pink
}

class AppCategories {
  static const List<Map<String, dynamic>> list = [
    {'name': 'Food & Dining', 'icon': Icons.restaurant, 'color': Color(0xFFFF7043)},
    {'name': 'Transportation', 'icon': Icons.directions_car, 'color': Color(0xFF42A5F5)},
    {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Color(0xFFEC407A)},
    {'name': 'Bills & Utilities', 'icon': Icons.receipt_long, 'color': Color(0xFFEF5350)},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Color(0xFFAB47BC)},
    {'name': 'Health & Medical', 'icon': Icons.local_hospital, 'color': Color(0xFF26A69A)},
    {'name': 'Education', 'icon': Icons.school, 'color': Color(0xFF29B6F6)},
    {'name': 'Personal Care', 'icon': Icons.face, 'color': Color(0xFFFFCA28)},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Color(0xFF26C6DA)},
    {'name': 'Others', 'icon': Icons.more_horiz, 'color': Color(0xFF90A4AE)},
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
