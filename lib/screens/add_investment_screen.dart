import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../widgets/glass_card.dart';
import '../providers/investment_provider.dart';
import '../models/investment.dart';

class AddInvestmentScreen extends StatefulWidget {
  final Investment? investment;
  const AddInvestmentScreen({super.key, this.investment});

  @override
  State<AddInvestmentScreen> createState() => _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends State<AddInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _tickerCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _buyPriceCtrl = TextEditingController();
  final _currentPriceCtrl = TextEditingController();

  String _type = InvestmentTypes.list.first;
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool get _isEdit => widget.investment != null;

  double get _totalCost {
    final qty = double.tryParse(_quantityCtrl.text) ?? 0;
    final buy = double.tryParse(_buyPriceCtrl.text) ?? 0;
    return qty * buy;
  }

  double get _currentValue {
    final qty = double.tryParse(_quantityCtrl.text) ?? 0;
    final cur = double.tryParse(_currentPriceCtrl.text) ?? 0;
    return qty * cur;
  }

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final inv = widget.investment!;
      _nameCtrl.text = inv.name;
      _tickerCtrl.text = inv.ticker ?? '';
      _quantityCtrl.text = inv.quantity.toString();
      _buyPriceCtrl.text = inv.buyPrice.toString();
      _currentPriceCtrl.text = inv.currentPrice.toString();
      _type = inv.type;
      _date = inv.date;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tickerCtrl.dispose();
    _quantityCtrl.dispose();
    _buyPriceCtrl.dispose();
    _currentPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final gainLoss = _currentValue - _totalCost;
    final isProfit = gainLoss >= 0;
    final gainColor = isProfit ? AppColors.income : AppColors.expense;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title:
              Text(_isEdit ? 'Edit Investment' : 'Add Investment')),
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
            // Live P&L preview
            if (_totalCost > 0)
              GlassCard(
                margin: const EdgeInsets.only(bottom: 16),
                backgroundColor:
                    gainColor.withValues(alpha: 0.12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PreviewStat(
                        label: 'Cost',
                        value: '₱ ${fmt.format(_totalCost)}'),
                    _PreviewStat(
                        label: 'Value',
                        value: '₱ ${fmt.format(_currentValue)}'),
                    _PreviewStat(
                      label: 'P&L',
                      value:
                          '${isProfit ? '+' : ''}₱ ${fmt.format(gainLoss)}',
                      color: gainColor,
                    ),
                  ],
                ),
              ),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.business_rounded)),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                  labelText: 'Type',
                  prefixIcon: Icon(Icons.category_rounded)),
              dropdownColor: const Color(0xFF2A2450),
              style: const TextStyle(color: Colors.white),
              items: InvestmentTypes.list
                  .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t,
                          style:
                              const TextStyle(color: Colors.white))))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tickerCtrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Ticker / Symbol (optional)',
                  prefixIcon: Icon(Icons.tag_rounded)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Quantity / Shares',
                  prefixIcon: Icon(Icons.numbers_rounded)),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter quantity';
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _buyPriceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Buy Price per unit',
                  prefixText: '₱ ',
                  prefixIcon: Icon(Icons.shopping_cart_rounded)),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter buy price';
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentPriceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Current Price per unit',
                  prefixText: '₱ ',
                  prefixIcon: Icon(Icons.price_change_rounded)),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Enter current price';
                }
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Date picker
            GlassCard(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.calendar_today_rounded,
                    color: AppColors.primary),
                title: const Text('Purchase Date',
                    style: TextStyle(color: Colors.white)),
                trailing: Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary),
                ),
                onTap: _pickDate,
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
                  : Text(_isEdit
                      ? 'Update Investment'
                      : 'Save Investment'),
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
      firstDate: DateTime(2000),
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
      final provider = context.read<InvestmentProvider>();
      if (_isEdit) {
        await provider.update(widget.investment!.copyWith(
          name: _nameCtrl.text.trim(),
          type: _type,
          ticker: _tickerCtrl.text.trim().isEmpty
              ? null
              : _tickerCtrl.text.trim().toUpperCase(),
          quantity: double.parse(_quantityCtrl.text),
          buyPrice: double.parse(_buyPriceCtrl.text),
          currentPrice: double.parse(_currentPriceCtrl.text),
          date: _date,
        ));
      } else {
        await provider.add(
          name: _nameCtrl.text.trim(),
          type: _type,
          ticker: _tickerCtrl.text.trim().isEmpty
              ? null
              : _tickerCtrl.text.trim().toUpperCase(),
          quantity: double.parse(_quantityCtrl.text),
          buyPrice: double.parse(_buyPriceCtrl.text),
          currentPrice: double.parse(_currentPriceCtrl.text),
          date: _date,
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

class _PreviewStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _PreviewStat(
      {required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color ?? Colors.white,
            )),
      ],
    );
  }
}
