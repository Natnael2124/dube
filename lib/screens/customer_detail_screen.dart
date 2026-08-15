import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:dube/database/db_helper.dart';
import 'package:dube/models/customer.dart';
import 'package:dube/models/customer_reliability.dart';
import 'package:dube/models/debt_history.dart';
import 'package:dube/models/debt_record.dart';
import 'package:dube/utils/formatters.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
    this.focusDebtId,
  });

  final int customerId;
  final int? focusDebtId;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Customer? _customer;
  List<DebtRecord> _debts = const [];
  List<DebtHistoryEntry> _history = const [];
  CustomerReliabilityStats _reliability = CustomerReliabilityStats.empty;
  double _outstanding = 0;
  bool _loading = true;
  String? _error;

  List<DebtRecord> get _openDebts =>
      _debts.where((debt) => !debt.isSettled).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final db = DbHelper.instance;
      await db.refreshOverdueStatuses();
      final customer = await db.getCustomerById(widget.customerId);
      if (customer == null) {
        throw StateError('Customer not found.');
      }
      final debts = await db.getDebtsForCustomer(widget.customerId);
      final history = await db.getHistoryForCustomer(widget.customerId);
      final outstanding = await db.getCustomerOutstanding(widget.customerId);
      final reliability =
          await db.getCustomerReliabilityStats(widget.customerId);

      if (!mounted) return;
      setState(() {
        _customer = customer;
        _debts = debts;
        _history = history;
        _outstanding = outstanding;
        _reliability = reliability;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<DebtRecord?> _pickDebt({
    required String title,
    bool openOnly = true,
  }) async {
    final list = openOnly ? _openDebts : _debts;
    if (list.isEmpty) {
      _showMessage(
        openOnly
            ? 'This customer has no open Dube.'
            : 'No Dube recorded for this customer.',
      );
      return null;
    }
    if (list.length == 1) return list.first;

    return showModalBottomSheet<DebtRecord>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                for (final debt in list)
                  ListTile(
                    leading: Icon(
                      debt.status == DebtStatus.overdue
                          ? Icons.warning_amber_rounded
                          : debt.isSettled
                              ? Icons.check_circle_outline
                              : Icons.receipt_long_outlined,
                      color: debt.status == DebtStatus.overdue
                          ? Theme.of(context).colorScheme.error
                          : debt.isSettled
                              ? const Color(0xFF2E7D32)
                              : null,
                    ),
                    title: Text(
                      debt.itemsDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      debt.isSettled
                          ? 'Settled · ${formatEtb(debt.totalAmount)}'
                          : '${formatEtb(debt.remainingBalance)} · due ${formatDateIso(debt.dueDate)}',
                    ),
                    onTap: () => Navigator.pop(context, debt),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _recordPayment([DebtRecord? targetDebt]) async {
    final debt =
        targetDebt ?? await _pickDebt(title: 'Which Dube is being paid?');
    if (debt == null || !mounted) return;

    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RecordPaymentDialog(debt: debt),
    );

    if (updated == true && mounted) {
      _showMessage('Payment updated successfully.');
      await _load();
    }
  }

  Future<void> _editDebt([DebtRecord? targetDebt]) async {
    final debt = targetDebt ??
        await _pickDebt(
          title: 'Which Dube do you want to edit?',
          openOnly: false,
        );
    if (debt == null || !mounted) return;

    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EditDebtDialog(debt: debt),
    );

    if (updated == true && mounted) {
      _showMessage('Dube updated successfully.');
      await _load();
    }
  }

  Future<void> _extendDueDate([DebtRecord? targetDebt]) async {
    final debt =
        targetDebt ?? await _pickDebt(title: 'Which Dube should be extended?');
    if (debt == null || !mounted) return;

    final initial = debt.dueDateTime.isAfter(DateTime.now())
        ? debt.dueDateTime
        : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: 'New due date',
    );
    if (picked == null || !mounted) return;

    try {
      await DbHelper.instance.extendDueDate(
        debtId: debt.id!,
        newDueDate: picked,
      );
      if (!mounted) return;
      _showMessage('Due date extended to ${formatDate(picked)}.');
      await _load();
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not extend due date: $error');
    }
  }

  Future<void> _sendSmsReminder() async {
    final customer = _customer;
    if (customer == null) return;
    if (_outstanding <= 0.005) {
      _showMessage('This customer has no outstanding Dube.');
      return;
    }

    final open = _openDebts;
    final items = open.map((d) => d.itemsDescription).join(', ');
    final earliest = open
        .map((d) => d.dueDateTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    final body =
        'Dear ${customer.name}, reminder from shop regarding your Dube '
        'balance of ${formatEtb(_outstanding)} for $items, '
        'due on ${formatDate(earliest)}.';

    final uri = Uri(
      scheme: 'sms',
      path: customer.phone,
      query: 'body=${Uri.encodeComponent(body)}',
    );

    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        _showMessage('Could not open the SMS app.');
      }
    } catch (error) {
      if (!mounted) return;
      _showMessage('Could not open SMS: $error');
    }
  }

  void _showDebtActionSheet(DebtRecord debt) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debt.itemsDescription,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        debt.isSettled
                            ? 'Settled · Total: ${formatEtb(debt.totalAmount)}'
                            : 'Remaining: ${formatEtb(debt.remainingBalance)} of ${formatEtb(debt.totalAmount)}',
                        style: TextStyle(
                          color: debt.isSettled
                              ? const Color(0xFF2E7D32)
                              : scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (!debt.isSettled) ...[
                  ListTile(
                    leading:
                        Icon(Icons.payments_outlined, color: scheme.primary),
                    title: const Text('Record Payment / Mark as Paid'),
                    subtitle:
                        const Text('Settle in full or make partial payment'),
                    onTap: () {
                      Navigator.pop(context);
                      _recordPayment(debt);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.event_repeat_outlined),
                    title: const Text('Extend Due Date'),
                    subtitle:
                        Text('Current due: ${formatDateIso(debt.dueDate)}'),
                    onTap: () {
                      Navigator.pop(context);
                      _extendDueDate(debt);
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.edit_note_outlined),
                  title: const Text('Edit / Adjust Dube'),
                  subtitle: const Text('Modify items, total amount, or notes'),
                  onTap: () {
                    Navigator.pop(context);
                    _editDebt(debt);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer?.name ?? 'Customer'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      _CustomerHeader(
                        customer: customer!,
                        outstanding: _outstanding,
                      ),
                      const SizedBox(height: 12),
                      _ReliabilityCard(stats: _reliability),
                      const SizedBox(height: 16),
                      _ActionRow(
                        onPay: () => _recordPayment(),
                        onEdit: () => _editDebt(),
                        onExtend: () => _extendDueDate(),
                        onSms: _sendSmsReminder,
                        hasOpenDebt: _openDebts.isNotEmpty,
                        hasAnyDebt: _debts.isNotEmpty,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Open & past Dube',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      if (_debts.isEmpty)
                        const _EmptyHint(
                          icon: Icons.inbox_outlined,
                          message: 'No Dube recorded for this customer yet.',
                        )
                      else
                        for (final debt in _debts)
                          _DebtTile(
                            debt: debt,
                            highlighted: debt.id == widget.focusDebtId,
                            onTap: () => _showDebtActionSheet(debt),
                          ),
                      const SizedBox(height: 24),
                      Text(
                        'Repayment & deadline timeline',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      if (_history.isEmpty)
                        const _EmptyHint(
                          icon: Icons.timeline,
                          message: 'No history yet.',
                        )
                      else
                        _HistoryTimeline(entries: _history),
                    ],
                  ),
                ),
    );
  }
}

class _ReliabilityCard extends StatelessWidget {
  const _ReliabilityCard({required this.stats});

  final CustomerReliabilityStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasOverdue = stats.overdueDebtsCount > 0;
    final isReliable = stats.settledDebtsCount > 0 && !hasOverdue;

    final badgeBg = hasOverdue
        ? scheme.errorContainer
        : isReliable
            ? const Color(0xFFE8F5E9)
            : scheme.surfaceContainerHighest;

    final badgeFg = hasOverdue
        ? scheme.onErrorContainer
        : isReliable
            ? const Color(0xFF1B5E20)
            : scheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: isReliable ? const Color(0xFF2E7D32) : scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Repayment Track Record',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: hasOverdue
                          ? scheme.error.withValues(alpha: 0.5)
                          : isReliable
                              ? const Color(0xFFA5D6A7)
                              : scheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    stats.trustLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: badgeFg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    label: 'Settled / Active',
                    value:
                        '${stats.settledDebtsCount} / ${stats.activeDebtsCount + stats.overdueDebtsCount}',
                    subtext: stats.overdueDebtsCount > 0
                        ? '⚠️ ${stats.overdueDebtsCount} overdue'
                        : '${stats.totalDebtsCount} total',
                    subtextColor: hasOverdue ? scheme.error : null,
                  ),
                ),
                Container(
                  width: 1,
                  height: 38,
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: _MetricItem(
                      label: 'On-Time Settlement',
                      value: stats.settledDebtsCount > 0
                          ? '${(stats.onTimeRate * 100).toStringAsFixed(0)}%'
                          : 'N/A',
                      subtext: stats.settledDebtsCount > 0
                          ? '${stats.onTimeSettledCount}/${stats.settledDebtsCount} on time'
                          : 'No history',
                      subtextColor: isReliable ? const Color(0xFF2E7D32) : null,
                    ),
                  ),
                ),
              ],
            ),
            if (stats.settledDebtsCount > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: stats.onTimeRate,
                  minHeight: 6,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stats.onTimeRate >= 0.8
                        ? const Color(0xFF2E7D32)
                        : stats.onTimeRate >= 0.5
                            ? const Color(0xFFF57F17)
                            : scheme.error,
                  ),
                ),
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Borrowed',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatEtb(stats.totalLifetimeBorrowed),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Repaid',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatEtb(stats.totalLifetimeRepaid),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.subtext,
    this.subtextColor,
  });

  final String label;
  final String value;
  final String subtext;
  final Color? subtextColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          subtext,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: subtextColor ?? scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

enum _PaymentMode { full, partial }

class _RecordPaymentDialog extends StatefulWidget {
  const _RecordPaymentDialog({required this.debt});

  final DebtRecord debt;

  @override
  State<_RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<_RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  _PaymentMode _mode = _PaymentMode.full;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: formatEtbCompact(widget.debt.remainingBalance),
    );
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;

    if (_mode == _PaymentMode.full) {
      setState(() => _saving = true);
      try {
        await DbHelper.instance.settleDebt(
          debtId: widget.debt.id!,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error settling Dube: $e')),
        );
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);
    try {
      await DbHelper.instance.recordPayment(
        debtId: widget.debt.id!,
        amount: amount,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording payment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final remaining = widget.debt.remainingBalance;

    return AlertDialog(
      title: const Text('Record Payment'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.debt.itemsDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Remaining Balance: ${formatEtb(remaining)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<_PaymentMode>(
                segments: const [
                  ButtonSegment(
                    value: _PaymentMode.full,
                    label: Text('Full Settlement'),
                    icon: Icon(Icons.check_circle_outline),
                  ),
                  ButtonSegment(
                    value: _PaymentMode.partial,
                    label: Text('Partial'),
                    icon: Icon(Icons.payments_outlined),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selected) {
                  setState(() {
                    _mode = selected.first;
                    if (_mode == _PaymentMode.full) {
                      _amountController.text = formatEtbCompact(remaining);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_mode == _PaymentMode.full)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF2E7D32),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Marks this Dube as settled in full with remaining balance ETB 0.00.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF1B5E20),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                TextFormField(
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Payment Amount (ETB)',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid payment amount';
                    }
                    if (parsed - remaining > 0.005) {
                      return 'Cannot exceed remaining balance (${formatEtb(remaining)})';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Payment note (optional)',
                  hintText: 'e.g. Cash, Telebirr, CBE transfer',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  _mode == _PaymentMode.full
                      ? 'Mark as Fully Paid'
                      : 'Save Payment',
                ),
        ),
      ],
    );
  }
}

class _EditDebtDialog extends StatefulWidget {
  const _EditDebtDialog({required this.debt});

  final DebtRecord debt;

  @override
  State<_EditDebtDialog> createState() => _EditDebtDialogState();
}

class _EditDebtDialogState extends State<_EditDebtDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemsController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _dueDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _itemsController = TextEditingController(
      text: widget.debt.itemsDescription,
    );
    _amountController = TextEditingController(
      text: formatEtbCompact(widget.debt.totalAmount),
    );
    _noteController = TextEditingController();
    _dueDate = widget.debt.dueDateTime;
  }

  @override
  void dispose() {
    _itemsController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: 'Adjust due date',
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    final totalAmount = double.tryParse(_amountController.text.trim());
    if (totalAmount == null || totalAmount <= 0) return;

    setState(() => _saving = true);
    try {
      await DbHelper.instance.updateDebt(
        debtId: widget.debt.id!,
        itemsDescription: _itemsController.text.trim(),
        totalAmount: totalAmount,
        dueDate: _dueDate,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating Dube: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Edit / Adjust Dube'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.debt.amountPaid > 0) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color:
                        scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Already paid: ${formatEtb(widget.debt.amountPaid)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              TextFormField(
                controller: _itemsController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Item details',
                  hintText: 'e.g. Sugar 2kg, Cooking oil 1L',
                  prefixIcon: Icon(Icons.shopping_basket_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Describe items';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Total Amount (ETB)',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid total amount';
                  }
                  if (parsed < widget.debt.amountPaid - 0.005) {
                    return 'Total cannot be less than already paid (${formatEtb(widget.debt.amountPaid)})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                onTap: _pickDueDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: scheme.outlineVariant),
                ),
                leading: Icon(Icons.event_outlined, color: scheme.primary),
                title: const Text('Due date'),
                subtitle: Text(formatDate(_dueDate)),
                trailing: const Icon(Icons.chevron_right),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Adjustment note (optional)',
                  hintText: 'e.g. Price discount, corrected items',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader({
    required this.customer,
    required this.outstanding,
  });

  final Customer customer;
  final double outstanding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                  child: Text(
                    customer.name.trim().isEmpty
                        ? '?'
                        : customer.name.trim()[0].toUpperCase(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.phone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((customer.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                customer.notes!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: outstanding > 0
                    ? scheme.secondaryContainer
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: outstanding > 0
                      ? Colors.transparent
                      : const Color(0xFFA5D6A7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total outstanding',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: outstanding > 0
                          ? scheme.onSecondaryContainer
                          : const Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatEtb(outstanding),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: outstanding > 0
                          ? scheme.onSecondaryContainer
                          : const Color(0xFF1B5E20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onPay,
    required this.onEdit,
    required this.onExtend,
    required this.onSms,
    required this.hasOpenDebt,
    required this.hasAnyDebt,
  });

  final VoidCallback onPay;
  final VoidCallback onEdit;
  final VoidCallback onExtend;
  final VoidCallback onSms;
  final bool hasOpenDebt;
  final bool hasAnyDebt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: hasOpenDebt ? onPay : null,
                icon: const Icon(Icons.payments_outlined),
                label: const Text('Record Payment'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasAnyDebt ? onEdit : null,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Edit / Adjust'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasOpenDebt ? onExtend : null,
                icon: const Icon(Icons.event_repeat_outlined),
                label: const Text('Extend Date'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasOpenDebt ? onSms : null,
                icon: const Icon(Icons.sms_outlined),
                label: const Text('SMS'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({
    required this.debt,
    required this.highlighted,
    required this.onTap,
  });

  final DebtRecord debt;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overdue = debt.status == DebtStatus.overdue;
    final settled = debt.isSettled;

    return Card(
      clipBehavior: Clip.antiAlias,
      color:
          highlighted ? scheme.primaryContainer.withValues(alpha: 0.45) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.itemsDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settled
                          ? 'Settled · ${formatEtb(debt.totalAmount)}'
                          : '${formatEtb(debt.remainingBalance)} remaining of ${formatEtb(debt.totalAmount)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: settled
                                ? const Color(0xFF2E7D32)
                                : scheme.primary,
                            fontWeight:
                                settled ? FontWeight.w600 : FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    settled
                        ? 'Settled'
                        : formatDateIso(debt.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: settled
                          ? const Color(0xFF2E7D32)
                          : overdue
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                      fontWeight: overdue || settled
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _StatusChip(status: debt.status),
                ],
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 20, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case DebtStatus.overdue:
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
        label = 'Overdue';
      case DebtStatus.settled:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF1B5E20);
        label = 'Settled (የተከፈለ)';
      default:
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
        label = 'Active';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: status == DebtStatus.settled
            ? Border.all(color: const Color(0xFFA5D6A7))
            : null,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _HistoryTimeline extends StatelessWidget {
  const _HistoryTimeline({required this.entries});

  final List<DebtHistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineTile(
            entry: entries[i],
            isLast: i == entries.length - 1,
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.entry,
    required this.isLast,
  });

  final DebtHistoryEntry entry;
  final bool isLast;

  IconData get _icon {
    switch (entry.history.actionType) {
      case HistoryAction.created:
        return Icons.add_circle_outline;
      case HistoryAction.partialPayment:
        return Icons.south_west;
      case HistoryAction.settled:
        return Icons.check_circle_outline;
      case HistoryAction.extendedDeadline:
        return Icons.event_repeat_outlined;
      case HistoryAction.adjusted:
        return Icons.edit_note_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final history = entry.history;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Icon(_icon, size: 20, color: scheme.primary),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    HistoryAction.label(history.actionType),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.itemsDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (history.amountChange != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      history.actionType == HistoryAction.created
                          ? 'Amount: ${formatEtb(history.amountChange!)}'
                          : history.actionType == HistoryAction.adjusted
                              ? 'Adjusted difference: ${formatEtb(history.amountChange!)}'
                              : 'Paid: ${formatEtb(history.amountChange!)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (history.newDueDate != null) ...[
                    const SizedBox(height: 2),
                    Text('Due: ${formatDateIso(history.newDueDate!)}'),
                  ],
                  if ((history.note ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      history.note!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    formatDateTimeIso(history.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
