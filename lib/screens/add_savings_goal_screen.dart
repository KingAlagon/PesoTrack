import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/savings_provider.dart';
import '../models/savings_goal.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  final SavingsGoal? goal;
  const AddSavingsGoalScreen({super.key, this.goal});

  @override
  State<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _currentCtrl = TextEditingController();

  DateTime? _deadline;
  Color _color = const Color(0xFF1565C0);
  bool _saving = false;

  bool get _isEdit => widget.goal != null;

  static const List<Color> _palette = [
    Color(0xFF1565C0), Color(0xFF2E7D32), Color(0xFFE65100),
    Color(0xFF6A1B9A), Color(0xFF00695C), Color(0xFFC62828),
    Color(0xFF4527A0), Color(0xFF00838F), Color(0xFF558B2F),
    Color(0xFFAD1457),
  ];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final g = widget.goal!;
      _nameCtrl.text = g.name;
      _targetCtrl.text = g.targetAmount.toString();
      _currentCtrl.text = g.currentAmount.toString();
      _deadline = g.deadline;
      _color = g.color;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Goal' : 'New Savings Goal')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Goal Name', prefixIcon: Icon(Icons.flag)),
              validator: (v) => v == null || v.isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Target Amount', prefixText: '₱ ', prefixIcon: Icon(Icons.track_changes)),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter target amount';
                if (double.tryParse(v) == null) return 'Invalid number';
                if (double.parse(v) <= 0) return 'Must be > 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Current Amount (optional)', prefixText: '₱ ', prefixIcon: Icon(Icons.savings)),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) return 'Invalid number';
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
              leading: const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
              title: const Text('Target Deadline'),
              trailing: Text(
                _deadline != null
                    ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                    : 'Optional',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _deadline != null ? const Color(0xFF212121) : const Color(0xFF757575),
                ),
              ),
              onTap: _pickDeadline,
            ),
            const SizedBox(height: 16),
            const Text('Goal Color', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _palette.map((c) => GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: _color == c ? Border.all(color: Colors.black, width: 3) : null,
                  ),
                  child: _color == c ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEdit ? 'Update Goal' : 'Create Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final provider = context.read<SavingsProvider>();
      final target = double.parse(_targetCtrl.text);
      final current = _currentCtrl.text.isEmpty ? 0.0 : double.parse(_currentCtrl.text);

      if (_isEdit) {
        await provider.update(widget.goal!.copyWith(
          name: _nameCtrl.text.trim(),
          targetAmount: target,
          currentAmount: current,
          deadline: _deadline,
          color: _color,
        ));
      } else {
        await provider.add(
          name: _nameCtrl.text.trim(),
          targetAmount: target,
          currentAmount: current,
          deadline: _deadline,
          color: _color,
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
