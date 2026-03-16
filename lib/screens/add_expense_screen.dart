import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../widgets/glass_card.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _category = AppCategories.list.first['name'] as String;
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.expense!;
      _titleCtrl.text = e.title;
      _amountCtrl.text = e.amount.toString();
      _noteCtrl.text = e.note ?? '';
      _category = e.category;
      _date = e.date;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title: Text(_isEdit ? 'Edit Expense' : 'Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
            left: 16,
            right: 16,
            bottom: 40,
          ),
          children: [
            // Amount field (prominent glass card)
            GlassCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              backgroundColor: AppColors.expense.withValues(alpha: 0.12),
              child: Column(
                children: [
                  const Text('Amount',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('₱',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(color: Colors.white38),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            fillColor: Colors.transparent,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter amount';
                            }
                            if (double.tryParse(v) == null) {
                              return 'Invalid number';
                            }
                            if (double.parse(v) <= 0) return 'Must be > 0';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Title
            TextFormField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 16),
            // Category picker
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded)),
              dropdownColor: const Color(0xFF2A2450),
              style: const TextStyle(color: Colors.white),
              items: AppCategories.list.map((cat) {
                return DropdownMenuItem(
                  value: cat['name'] as String,
                  child: Row(
                    children: [
                      Icon(cat['icon'] as IconData,
                          color: cat['color'] as Color, size: 20),
                      const SizedBox(width: 8),
                      Text(cat['name'] as String,
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            // Date picker
            GlassCard(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary),
                title: const Text('Date',
                    style: TextStyle(color: Colors.white)),
                trailing: Text(DateFormat('MMM d, y').format(_date),
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary)),
                onTap: _pickDate,
              ),
            ),
            const SizedBox(height: 16),
            // Note
            TextFormField(
              controller: _noteCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.note_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'Update Expense' : 'Save Expense',
                      style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: Color(0xFF1E1A40),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final provider = context.read<ExpenseProvider>();
      final amount = double.parse(_amountCtrl.text);

      if (_isEdit) {
        await provider.update(widget.expense!.copyWith(
          title: _titleCtrl.text.trim(),
          amount: amount,
          category: _category,
          date: _date,
          note: _noteCtrl.text.trim().isEmpty
              ? null
              : _noteCtrl.text.trim(),
        ));
      } else {
        await provider.add(
          title: _titleCtrl.text.trim(),
          amount: amount,
          category: _category,
          date: _date,
          note: _noteCtrl.text.trim().isEmpty
              ? null
              : _noteCtrl.text.trim(),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
