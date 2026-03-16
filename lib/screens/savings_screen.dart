import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../widgets/glass_card.dart';
import '../providers/savings_provider.dart';
import '../models/savings_goal.dart';
import 'add_savings_goal_screen.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavingsProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Savings Goals')),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : provider.goals.isEmpty
              ? const _EmptyState()
              : ListView(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        8,
                    bottom: 100,
                  ),
                  children: [
                    _SummaryBanner(provider: provider),
                    ...provider.goals
                        .map((g) => _GoalCard(goal: g, provider: provider)),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(
                builder: (_) => const AddSavingsGoalScreen())),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final SavingsProvider provider;
  const _SummaryBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final overallProgress = provider.totalTarget > 0
        ? (provider.totalSaved / provider.totalTarget).clamp(0.0, 1.0)
        : 0.0;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: AppColors.accent.withValues(alpha: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.savings_rounded,
                    color: AppColors.accent, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Saved',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  Text('₱ ${fmt.format(provider.totalSaved)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Target: ₱ ${fmt.format(provider.totalTarget)}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                  '${provider.completedCount}/${provider.goals.length} done',
                  style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: overallProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.accent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final SavingsProvider provider;
  const _GoalCard({required this.goal, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: goal.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: goal.color.withValues(alpha: 0.5),
                        blurRadius: 6)
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(goal.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white))),
              if (goal.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            AppColors.success.withValues(alpha: 0.4)),
                  ),
                  child: const Text('Completed!',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.textSecondary),
                onSelected: (v) => _onMenu(context, v),
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                      value: 'add', child: Text('Add Funds')),
                  const PopupMenuItem(
                      value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: AppColors.error))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Text('₱ ${fmt.format(goal.currentAmount)}',
                style: TextStyle(
                    color: goal.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text('/ ₱ ${fmt.format(goal.targetAmount)}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: goal.color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(goal.color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${(goal.progress * 100).toStringAsFixed(1)}% saved',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
            if (!goal.isCompleted)
              Text('₱ ${fmt.format(goal.remaining)} remaining',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            if (goal.deadline != null)
              Text(
                  'Due ${DateFormat('MMM d, y').format(goal.deadline!)}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  void _onMenu(BuildContext context, String action) {
    switch (action) {
      case 'add':
        _showAddFunds(context);
      case 'edit':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddSavingsGoalScreen(goal: goal)));
      case 'delete':
        _confirmDelete(context);
    }
  }

  void _showAddFunds(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to ${goal.name}'),
        content: TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '₱ ',
            labelText: 'Amount',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(ctrl.text);
              if (amount != null && amount > 0) {
                provider.addFunds(goal.id, amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Delete "${goal.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.delete(goal.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
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
          Icon(Icons.savings_rounded, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('No savings goals yet',
              style: TextStyle(
                  fontSize: 18, color: AppColors.textSecondary)),
          Text('Tap + to create your first goal',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
