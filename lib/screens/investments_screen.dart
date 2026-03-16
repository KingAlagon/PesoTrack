import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../widgets/glass_card.dart';
import '../providers/investment_provider.dart';
import '../models/investment.dart';
import 'add_investment_screen.dart';

class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvestmentProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Investments')),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : provider.investments.isEmpty
              ? const _EmptyState()
              : ListView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        8,
                    bottom: 100,
                  ),
                  children: [
                    _PortfolioSummary(provider: provider),
                    ...provider.investments.map((inv) => _InvestmentCard(
                          investment: inv,
                          provider: provider,
                        )),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddInvestmentScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Add Investment'),
      ),
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  final InvestmentProvider provider;
  const _PortfolioSummary({required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final isProfit = provider.isOverallProfit;
    final color = isProfit ? AppColors.income : AppColors.expense;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: color.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                    isProfit
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: color,
                    size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Portfolio Value',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  Text('₱ ${fmt.format(provider.totalCurrentValue)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(
                    isProfit
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: color,
                    size: 16),
                const SizedBox(width: 4),
                Text(
                  '${isProfit ? '+' : ''}₱ ${fmt.format(provider.totalGainLoss)} '
                  '(${provider.totalGainLossPercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ]),
              Text('Invested: ₱ ${fmt.format(provider.totalInvested)}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final Investment investment;
  final InvestmentProvider provider;
  const _InvestmentCard(
      {required this.investment, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final isProfit = investment.isProfit;
    final gainColor = isProfit ? AppColors.income : AppColors.expense;
    final gainIcon = isProfit
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return Dismissible(
      key: Key(investment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (dir) async => await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Investment'),
          content: Text('Delete "${investment.name}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
      onDismissed: (_) => provider.delete(investment.id),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(investment.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white)),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Text(investment.type,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500)),
                        ),
                        if (investment.ticker != null) ...[
                          const SizedBox(width: 6),
                          Text(investment.ticker!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₱ ${fmt.format(investment.currentValue)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white)),
                    Row(children: [
                      Icon(gainIcon, color: gainColor, size: 14),
                      Text(
                        '₱ ${fmt.format(investment.gainLoss.abs())} (${investment.gainLossPercent.toStringAsFixed(2)}%)',
                        style: TextStyle(
                            color: gainColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ]),
                  ],
                ),
              ],
            ),
            Divider(
                height: 20, color: Colors.white.withValues(alpha: 0.1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailItem(
                    label: 'Qty',
                    value: investment.quantity.toString()),
                _DetailItem(
                    label: 'Buy Price',
                    value: '₱ ${fmt.format(investment.buyPrice)}'),
                _DetailItem(
                    label: 'Current',
                    value: '₱ ${fmt.format(investment.currentPrice)}'),
                _DetailItem(
                    label: 'Cost',
                    value: '₱ ${fmt.format(investment.totalCost)}'),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            AddInvestmentScreen(investment: investment))),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up_rounded,
              size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('No investments yet',
              style: TextStyle(
                  fontSize: 18, color: AppColors.textSecondary)),
          Text('Tap + to track your portfolio',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
