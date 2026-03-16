import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final categories = ['All', ...AppCategories.names];

    final filtered = _selectedCategory == 'All'
        ? provider.expenses
        : provider.expenses.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = categories[i];
                final selected = _selectedCategory == cat;
                return FilterChip(
                  label: Text(cat, style: TextStyle(fontSize: 12, color: selected ? Colors.white : AppColors.textPrimary)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  checkmarkColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                );
              },
            ),
          ),
          // Total banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory == 'All' ? 'All expenses' : _selectedCategory,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '₱ ${NumberFormat('#,##0.00').format(filtered.fold(0.0, (s, e) => s + e.amount))}',
                  style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) => _ExpenseTile(
                          expense: filtered[i],
                          onDelete: () => provider.delete(filtered[i].id),
                          onEdit: () => _openEdit(context, filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  void _openAdd(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
  }

  void _openEdit(BuildContext context, Expense expense) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpenseScreen(expense: expense)));
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text('No expenses yet', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
          Text('Tap + to log your first expense', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ExpenseTile({required this.expense, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final color = AppCategories.getColor(expense.category);
    final fmt = NumberFormat('#,##0.00');

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: AppColors.error,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Expense'),
            content: Text('Delete "${expense.title}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete', style: TextStyle(color: AppColors.error))),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(AppCategories.getIcon(expense.category), color: color, size: 22),
          ),
          title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(expense.category, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(DateFormat('MMM d, y').format(expense.date),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('-₱ ${fmt.format(expense.amount)}',
                  style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.bold, fontSize: 15)),
              if (expense.note != null && expense.note!.isNotEmpty)
                const Icon(Icons.note, size: 14, color: AppColors.textSecondary),
            ],
          ),
          onTap: onEdit,
        ),
      ),
    );
  }
}
