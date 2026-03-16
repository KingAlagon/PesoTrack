import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants.dart';
import '../providers/piggy_bank_provider.dart';

class PiggyBankScreen extends StatelessWidget {
  const PiggyBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PiggyBankProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Piggy Bank'),
        actions: [
          if (provider.hasSetup)
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') _showEditDialog(context, provider);
                if (v == 'reset') _confirmReset(context, provider);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit Target')),
                const PopupMenuItem(
                    value: 'reset',
                    child: Text('Reset', style: TextStyle(color: AppColors.error))),
              ],
            ),
        ],
      ),
      body: provider.hasSetup
          ? _PiggyBankView(provider: provider)
          : _SetupView(provider: provider),
    );
  }

  void _showEditDialog(BuildContext context, PiggyBankProvider provider) {
    final nameCtrl = TextEditingController(text: provider.piggyBank!.name);
    final targetCtrl =
        TextEditingController(text: provider.piggyBank!.targetAmount.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Target'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: targetCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Target Amount', prefixText: '₱ '),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null || double.parse(v) <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                provider.updateTarget(
                  name: nameCtrl.text.trim(),
                  targetAmount: double.parse(targetCtrl.text),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, PiggyBankProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Piggy Bank'),
        content: const Text('This will clear all saved amount and settings. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.reset();
              Navigator.pop(ctx);
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Setup View ────────────────────────────────────────────────────────────
class _SetupView extends StatefulWidget {
  final PiggyBankProvider provider;
  const _SetupView({required this.provider});

  @override
  State<_SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<_SetupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'My Piggy Bank');
  final _targetCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('🐷', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              const Text('Set Up Your Piggy Bank',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Set a savings target and start putting money in!',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Piggy Bank Name', prefixIcon: Icon(Icons.edit)),
                validator: (v) => v == null || v.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Savings Target',
                  prefixText: '₱ ',
                  prefixIcon: Icon(Icons.track_changes),
                  hintText: 'e.g. 10000',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter a target amount';
                  if (double.tryParse(v) == null || double.parse(v) <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _submit,
                  icon: const Text('🐷', style: TextStyle(fontSize: 18)),
                  label: const Text('Create Piggy Bank', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.provider.setup(
        name: _nameCtrl.text.trim(),
        targetAmount: double.parse(_targetCtrl.text),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

// ── Piggy Bank View ───────────────────────────────────────────────────────
class _PiggyBankView extends StatelessWidget {
  final PiggyBankProvider provider;
  const _PiggyBankView({required this.provider});

  @override
  Widget build(BuildContext context) {
    final pig = provider.piggyBank!;
    final fmt = NumberFormat('#,##0.00');
    final pct = pig.progress * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ── Circular progress ──
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: pig.progress,
                  strokeWidth: 18,
                  backgroundColor: const Color(0xFFFCE4EC),
                  valueColor: AlwaysStoppedAnimation(
                    pig.isCompleted ? AppColors.success : const Color(0xFFE91E63),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pig.isCompleted ? '🎉' : '🐷',
                    style: const TextStyle(fontSize: 56),
                  ),
                  Text(
                    '${pct.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Name & amounts ──
          Text(pig.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (pig.isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('🎉 Goal Reached!',
                  style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AmountCard(
                  label: 'Saved',
                  value: '₱ ${fmt.format(pig.currentAmount)}',
                  color: AppColors.income),
              _AmountCard(
                  label: 'Target',
                  value: '₱ ${fmt.format(pig.targetAmount)}',
                  color: AppColors.primary),
              _AmountCard(
                  label: 'Remaining',
                  value: '₱ ${fmt.format(pig.remaining)}',
                  color: pig.isCompleted ? AppColors.success : AppColors.warning),
            ],
          ),
          const SizedBox(height: 32),

          // ── Action buttons ──
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddMoneyDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Money'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pig.currentAmount > 0
                      ? () => _showWithdrawDialog(context)
                      : null,
                  icon: const Icon(Icons.remove),
                  label: const Text('Withdraw'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Text('🐷', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Add Money'),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Amount to save',
              prefixText: '₱ ',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter an amount';
              if (double.tryParse(v) == null || double.parse(v) <= 0) {
                return 'Enter a valid amount';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                provider.addMoney(double.parse(ctrl.text));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('₱ ${ctrl.text} added to your piggy bank! 🐷'),
                    backgroundColor: const Color(0xFFE91E63),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Amount to withdraw',
              prefixText: '₱ ',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter an amount';
              final amount = double.tryParse(v);
              if (amount == null || amount <= 0) return 'Enter a valid amount';
              if (amount > provider.piggyBank!.currentAmount) {
                return 'Not enough savings';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                provider.withdraw(double.parse(ctrl.text));
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AmountCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
