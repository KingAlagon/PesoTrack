import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../models/budget.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = context.watch<BudgetProvider>();
    final expenses = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: budgets.isLoading
          ? const Center(child: CircularProgressIndicator())
          : budgets.budgets.isEmpty
              ? _EmptyState(onAdd: () => _showAddSheet(context, expenses))
              : ListView(
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    _AlertsBanner(budgets: budgets, expenses: expenses),
                    ...budgets.budgets.map((b) => _BudgetCard(
                          budget: b,
                          spent: expenses.spentForCategory(b.category, b.period),
                          onEdit: () => _showAddSheet(context, expenses, budget: b),
                          onDelete: () => budgets.delete(b.id),
                        )),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, expenses),
        icon: const Icon(Icons.add),
        label: const Text('Set Budget'),
      ),
    );
  }

  void _showAddSheet(BuildContext context, ExpenseProvider expenses, {Budget? budget}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddBudgetSheet(budget: budget),
    );
  }
}

// ── Alerts banner ─────────────────────────────────────────────────────────
class _AlertsBanner extends StatelessWidget {
  final BudgetProvider budgets;
  final ExpenseProvider expenses;
  const _AlertsBanner({required this.budgets, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final over = budgets.budgets.where((b) {
      final spent = expenses.spentForCategory(b.category, b.period);
      return spent > b.limitAmount;
    }).toList();

    if (over.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('All budgets are on track!',
                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.warning_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text('${over.length} budget${over.length > 1 ? 's' : ''} exceeded!',
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
          const SizedBox(height: 4),
          ...over.map((b) => Text('• ${b.category}',
              style: const TextStyle(color: AppColors.error, fontSize: 13))),
        ],
      ),
    );
  }
}

// ── Budget Card ────────────────────────────────────────────────────────────
class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final progress = (spent / budget.limitAmount).clamp(0.0, 1.0);
    final isOver = spent > budget.limitAmount;
    final progressColor = isOver
        ? AppColors.error
        : progress > 0.8
            ? AppColors.warning
            : AppColors.primary;
    final catColor = AppCategories.getColor(budget.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: catColor.withValues(alpha: 0.15),
                  child: Icon(AppCategories.getIcon(budget.category), color: catColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(budget.category,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(budget.period == 'monthly' ? 'Monthly Budget' : 'Weekly Budget',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') _confirmDelete(context);
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Spent', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('₱ ${fmt.format(spent)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18, color: progressColor)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('Limit', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text('₱ ${fmt.format(budget.limitAmount)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ]),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: progressColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(progressColor),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).toStringAsFixed(1)}% used',
                    style: TextStyle(fontSize: 12, color: progressColor, fontWeight: FontWeight.w500)),
                if (isOver)
                  Text('Over by ₱ ${fmt.format(spent - budget.limitAmount)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.bold))
                else
                  Text('₱ ${fmt.format(budget.limitAmount - spent)} left',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Remove budget for "${budget.category}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () { onDelete(); Navigator.pop(ctx); },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Add/Edit Budget Sheet ─────────────────────────────────────────────────
class _AddBudgetSheet extends StatefulWidget {
  final Budget? budget;
  const _AddBudgetSheet({this.budget});

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _limitCtrl = TextEditingController();
  String _category = AppCategories.list.first['name'] as String;
  String _period = 'monthly';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _category = widget.budget!.category;
      _limitCtrl.text = widget.budget!.limitAmount.toString();
      _period = widget.budget!.period;
    }
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.budget != null ? 'Edit Budget' : 'Set Budget',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
              items: AppCategories.list.map((cat) {
                return DropdownMenuItem(
                  value: cat['name'] as String,
                  child: Row(children: [
                    Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 18),
                    const SizedBox(width: 8),
                    Text(cat['name'] as String),
                  ]),
                );
              }).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _limitCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Budget Limit', prefixText: '₱ ', prefixIcon: Icon(Icons.money)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter limit';
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(children: [
              const Text('Period: ', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Monthly'),
                selected: _period == 'monthly',
                onSelected: (_) => setState(() => _period = 'monthly'),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: _period == 'monthly' ? Colors.white : AppColors.textPrimary),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Weekly'),
                selected: _period == 'weekly',
                onSelected: (_) => setState(() => _period = 'weekly'),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: _period == 'weekly' ? Colors.white : AppColors.textPrimary),
              ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                child: _saving
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(widget.budget != null ? 'Update Budget' : 'Set Budget'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await context.read<BudgetProvider>().add(
            category: _category,
            limitAmount: double.parse(_limitCtrl.text),
            period: _period,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Empty State ───────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text('No budgets set', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
          const Text('Set budget limits to track your spending',
              style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Set First Budget'),
          ),
        ],
      ),
    );
  }
}
