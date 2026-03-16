import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
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
      appBar: AppBar(title: Text(_isEdit ? 'Edit Investment' : 'Add Investment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Live P&L preview
            if (_totalCost > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: gainColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: gainColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PreviewStat(label: 'Cost', value: '₱ ${fmt.format(_totalCost)}'),
                    _PreviewStat(label: 'Value', value: '₱ ${fmt.format(_currentValue)}'),
                    _PreviewStat(
                      label: 'P&L',
                      value: '${isProfit ? '+' : ''}₱ ${fmt.format(gainLoss)}',
                      color: gainColor,
                    ),
                  ],
                ),
              ),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.business)),
              validator: (v) => v == null || v.isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type', prefixIcon: Icon(Icons.category)),
              items: InvestmentTypes.list
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tickerCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Ticker / Symbol (optional)', prefixIcon: Icon(Icons.tag)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantity / Shares', prefixIcon: Icon(Icons.numbers)),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Buy Price per unit', prefixText: '₱ ', prefixIcon: Icon(Icons.shopping_cart)),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Current Price per unit', prefixText: '₱ ', prefixIcon: Icon(Icons.price_change)),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter current price';
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              leading: const Icon(Icons.calendar_today, color: AppColors.primary),
              title: const Text('Purchase Date'),
              trailing: Text(
                '${_date.day}/${_date.month}/${_date.year}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'Update Investment' : 'Save Investment'),
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
          ticker: _tickerCtrl.text.trim().isEmpty ? null : _tickerCtrl.text.trim().toUpperCase(),
          quantity: double.parse(_quantityCtrl.text),
          buyPrice: double.parse(_buyPriceCtrl.text),
          currentPrice: double.parse(_currentPriceCtrl.text),
          date: _date,
        ));
      } else {
        await provider.add(
          name: _nameCtrl.text.trim(),
          type: _type,
          ticker: _tickerCtrl.text.trim().isEmpty ? null : _tickerCtrl.text.trim().toUpperCase(),
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
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
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
  const _PreviewStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color ?? AppColors.textPrimary,
            )),
      ],
    );
  }
}
