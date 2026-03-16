import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../widgets/glass_card.dart';
import '../providers/savings_provider.dart';
import '../models/savings_goal.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  final SavingsGoal? goal;
  const AddSavingsGoalScreen({super.key, this.goal});

  @override
  State<AddSavingsGoalScreen> createState() =>
      _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _currentCtrl = TextEditingController();

  DateTime? _deadline;
  Color _color = const Color(0xFF7C5CBF);
  bool _saving = false;

  bool get _isEdit => widget.goal != null;

  static const List<Color> _palette = [
    Color(0xFF7C5CBF), Color(0xFF00D4AA), Color(0xFFFF6B9D),
    Color(0xFF42A5F5), Color(0xFF4ADE80), Color(0xFFFBBF24),
    Color(0xFFF87171), Color(0xFFAB47BC), Color(0xFF26C6DA),
    Color(0xFFFF7043),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          title:
              Text(_isEdit ? 'Edit Goal' : 'New Savings Goal')),
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
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  prefixIcon: Icon(Icons.flag_rounded)),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  prefixText: '₱ ',
                  prefixIcon: Icon(Icons.track_changes_rounded)),
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: 'Current Amount (optional)',
                  prefixText: '₱ ',
                  prefixIcon: Icon(Icons.savings_rounded)),
              validator: (v) {
                if (v != null &&
                    v.isNotEmpty &&
                    double.tryParse(v) == null) {
                  return 'Invalid number';
                }
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
                title: const Text('Target Deadline',
                    style: TextStyle(color: Colors.white)),
                trailing: Text(
                  _deadline != null
                      ? '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'
                      : 'Optional',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _deadline != null
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
                onTap: _pickDeadline,
              ),
            ),
            const SizedBox(height: 16),
            // Color picker
            GlassCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Goal Color',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _palette.map((c) {
                      final selected = _color == c;
                      return GestureDetector(
                        onTap: () => setState(() => _color = c),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(
                                    color: Colors.white, width: 3)
                                : Border.all(
                                    color: c.withValues(alpha: 0.4),
                                    width: 1),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                        color: c.withValues(alpha: 0.5),
                                        blurRadius: 8)
                                  ]
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
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
      initialDate:
          _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
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
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final provider = context.read<SavingsProvider>();
      final target = double.parse(_targetCtrl.text);
      final current =
          _currentCtrl.text.isEmpty ? 0.0 : double.parse(_currentCtrl.text);

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
