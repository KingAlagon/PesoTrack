import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../widgets/glass_card.dart';
import '../providers/expense_provider.dart';
import '../providers/savings_provider.dart';
import '../providers/investment_provider.dart';
import '../providers/piggy_bank_provider.dart';
import '../models/expense.dart';
import 'piggy_bank_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();
    final savings = context.watch<SavingsProvider>();
    final investments = context.watch<InvestmentProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _GlassAppBar(title: 'PesoTrack'),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: const Color(0xFF1E1A40),
        onRefresh: () async {
          await expenses.load();
          await savings.load();
          await investments.load();
        },
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
            bottom: 100,
          ),
          children: [
            _SummaryHeader(expenses: expenses, investments: investments, savings: savings),
            _QuickStats(expenses: expenses),
            _PiggyBankCard(),
            if (expenses.categoryTotalsThisMonth.isNotEmpty)
              _SpendingChart(expenses: expenses),
            _SavingsOverview(savings: savings),
            _InvestmentSummary(investments: investments),
            _RecentTransactions(expenses: expenses),
          ],
        ),
      ),
    );
  }
}

// ── Glass AppBar ─────────────────────────────────────────────────────────────
class _GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _GlassAppBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Image.asset(
            'assets/images/logo.png',
            width: 30,
            height: 30,
            errorBuilder: (ctx, e, st) =>
                const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

// ── Summary Header ────────────────────────────────────────────────────────────
class _SummaryHeader extends StatelessWidget {
  final ExpenseProvider expenses;
  final InvestmentProvider investments;
  final SavingsProvider savings;

  const _SummaryHeader(
      {required this.expenses, required this.investments, required this.savings});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_PH');
    final netWorth = savings.totalSaved + investments.totalCurrentValue;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      backgroundColor: Colors.white.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                const Text('Net Worth',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$currencySymbol ${fmt.format(netWorth)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                    label: 'Saved',
                    value: savings.totalSaved,
                    icon: Icons.savings_rounded,
                    color: AppColors.accent),
              ),
              Container(width: 1, height: 44, color: Colors.white12),
              Expanded(
                child: _HeaderStat(
                    label: 'Invested',
                    value: investments.totalCurrentValue,
                    icon: Icons.trending_up_rounded,
                    color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  const _HeaderStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_PH');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                Text('₱ ${fmt.format(value)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats ───────────────────────────────────────────────────────────────
class _QuickStats extends StatelessWidget {
  final ExpenseProvider expenses;
  const _QuickStats({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_PH');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'This Month',
              value: '₱ ${fmt.format(expenses.totalThisMonth)}',
              icon: Icons.calendar_month_rounded,
              color: AppColors.expense,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'This Week',
              value: '₱ ${fmt.format(expenses.totalThisWeek)}',
              icon: Icons.date_range_rounded,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Spending Pie Chart ────────────────────────────────────────────────────────
class _SpendingChart extends StatelessWidget {
  final ExpenseProvider expenses;
  const _SpendingChart({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final totals = expenses.categoryTotalsThisMonth;
    final total = totals.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return const SizedBox();

    final sections = totals.entries.map((e) {
      final pct = (e.value / total) * 100;
      return PieChartSectionData(
        color: AppCategories.getColor(e.key),
        value: e.value,
        title: pct > 8 ? '${pct.toStringAsFixed(0)}%' : '',
        radius: 55,
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spending by Category',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white)),
          const Text('This month',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(PieChartData(
                    sections: sections,
                    centerSpaceRadius: 36,
                    sectionsSpace: 2,
                  )),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: totals.entries.take(5).map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: AppCategories.getColor(e.key),
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(e.key.split(' ').first,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.white70)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Savings Overview ──────────────────────────────────────────────────────────
class _SavingsOverview extends StatelessWidget {
  final SavingsProvider savings;
  const _SavingsOverview({required this.savings});

  @override
  Widget build(BuildContext context) {
    if (savings.goals.isEmpty) return const SizedBox();
    final fmt = NumberFormat('#,##0.00', 'en_PH');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.savings_rounded,
                  color: AppColors.accent, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Savings Goals',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${savings.completedCount}/${savings.goals.length} done',
                  style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 14),
          ...savings.goals.take(3).map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(g.name,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white)),
                          Text(
                              '₱ ${fmt.format(g.currentAmount)} / ₱ ${fmt.format(g.targetAmount)}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ]),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: g.progress,
                        backgroundColor: g.color.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(g.color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ── Investment Summary ────────────────────────────────────────────────────────
class _InvestmentSummary extends StatelessWidget {
  final InvestmentProvider investments;
  const _InvestmentSummary({required this.investments});

  @override
  Widget build(BuildContext context) {
    if (investments.investments.isEmpty) return const SizedBox();
    final fmt = NumberFormat('#,##0.00', 'en_PH');
    final isProfit = investments.isOverallProfit;
    final color = isProfit ? AppColors.income : AppColors.expense;

    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
                isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: color,
                size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Portfolio',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white)),
                Text('₱ ${fmt.format(investments.totalCurrentValue)}',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(
                  '${isProfit ? '+' : ''}₱ ${fmt.format(investments.totalGainLoss)} '
                  '(${investments.totalGainLossPercent.toStringAsFixed(2)}%)',
                  style: TextStyle(color: color, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Transactions ───────────────────────────────────────────────────────
class _RecentTransactions extends StatelessWidget {
  final ExpenseProvider expenses;
  const _RecentTransactions({required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.recentExpenses.isEmpty) return const SizedBox();
    final fmt = NumberFormat('#,##0.00', 'en_PH');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Transactions',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white)),
          const SizedBox(height: 8),
          ...expenses.recentExpenses
              .map((e) => _TransactionTile(expense: e, fmt: fmt)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Expense expense;
  final NumberFormat fmt;
  const _TransactionTile({required this.expense, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final color = AppCategories.getColor(expense.category);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(AppCategories.getIcon(expense.category),
            color: color, size: 20),
      ),
      title: Text(expense.title,
          style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.white)),
      subtitle: Text(DateFormat('MMM d, y').format(expense.date),
          style:
              const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: Text('-₱ ${fmt.format(expense.amount)}',
          style: const TextStyle(
              color: AppColors.expense,
              fontWeight: FontWeight.bold,
              fontSize: 14)),
    );
  }
}

// ── Piggy Bank Card ───────────────────────────────────────────────────────────
class _PiggyBankCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PiggyBankProvider>();
    final pig = provider.piggyBank;
    final fmt = NumberFormat('#,##0.00');
    const pinkColor = Color(0xFFFF6B9D);

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const PiggyBankScreen())),
      child: GlassCard(
        child: pig == null
            ? Row(children: [
                const Text('🐷', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Piggy Bank',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                        const Text('Tap to set up your savings target',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ]),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('🐷', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(pig.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pinkColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: pinkColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${(pig.progress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: pinkColor),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pig.progress,
                    backgroundColor: pinkColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(
                        pig.isCompleted ? AppColors.success : pinkColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₱ ${fmt.format(pig.currentAmount)} saved',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                      Text('Target: ₱ ${fmt.format(pig.targetAmount)}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ]),
              ]),
      ),
    );
  }
}
