import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../providers/investment_provider.dart';
import '../models/investment.dart';
import 'add_investment_screen.dart';

class InvestmentsScreen extends StatelessWidget {
  const InvestmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvestmentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Investments')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.investments.isEmpty
              ? _EmptyState()
              : ListView(
                  padding: const EdgeInsets.only(bottom: 80),
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
            context, MaterialPageRoute(builder: (_) => const AddInvestmentScreen())),
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

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isProfit
              ? [const Color(0xFF1B5E20), const Color(0xFF388E3C)]
              : [const Color(0xFFB71C1C), const Color(0xFFE53935)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 13)),
          Text('₱ ${fmt.format(provider.totalCurrentValue)}',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Icon(isProfit ? Icons.trending_up : Icons.trending_down, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              '${isProfit ? '+' : ''}₱ ${fmt.format(provider.totalGainLoss)} '
              '(${provider.totalGainLossPercent.toStringAsFixed(2)}%)',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ]),
          const SizedBox(height: 8),
          Text('Invested: ₱ ${fmt.format(provider.totalInvested)}',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final Investment investment;
  final InvestmentProvider provider;
  const _InvestmentCard({required this.investment, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final isProfit = investment.isProfit;
    final gainColor = isProfit ? AppColors.income : AppColors.expense;
    final gainIcon = isProfit ? Icons.arrow_upward : Icons.arrow_downward;

    return Dismissible(
      key: Key(investment.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: AppColors.error,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (dir) async => await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Investment'),
          content: Text('Delete "${investment.name}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
      onDismissed: (_) => provider.delete(investment.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(investment.type,
                                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                          ),
                          if (investment.ticker != null) ...[
                            const SizedBox(width: 6),
                            Text(investment.ticker!,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ]),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₱ ${fmt.format(investment.currentValue)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Row(children: [
                        Icon(gainIcon, color: gainColor, size: 14),
                        Text(
                          '₱ ${fmt.format(investment.gainLoss.abs())} (${investment.gainLossPercent.toStringAsFixed(2)}%)',
                          style: TextStyle(color: gainColor, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ]),
                    ],
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DetailItem(label: 'Qty', value: investment.quantity.toString()),
                  _DetailItem(label: 'Buy Price', value: '₱ ${fmt.format(investment.buyPrice)}'),
                  _DetailItem(label: 'Current', value: '₱ ${fmt.format(investment.currentPrice)}'),
                  _DetailItem(label: 'Cost', value: '₱ ${fmt.format(investment.totalCost)}'),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AddInvestmentScreen(investment: investment))),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
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
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('No investments yet', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
          Text('Tap + to track your portfolio', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
