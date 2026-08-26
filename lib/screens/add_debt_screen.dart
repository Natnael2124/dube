import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:dube/database/db_helper.dart';
import 'package:dube/l10n/app_localizations.dart';
import 'package:dube/models/customer.dart';
import 'package:dube/models/customer_reliability.dart';
import 'package:dube/utils/formatters.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _itemsController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  Customer? _existingCustomer;
  CustomerReliabilityStats? _reliabilityStats;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _itemsController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _lookupCustomer(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.length < 7) {
      if (_existingCustomer != null || _reliabilityStats != null) {
        setState(() {
          _existingCustomer = null;
          _reliabilityStats = null;
        });
      }
      return;
    }
    final match = await DbHelper.instance.getCustomerByPhone(trimmed);
    CustomerReliabilityStats? stats;
    if (match != null && match.id != null) {
      stats = await DbHelper.instance.getCustomerReliabilityStats(match.id!);
    }
    if (!mounted) return;
    setState(() {
      _existingCustomer = match;
      _reliabilityStats = stats;
    });
    if (match != null && _nameController.text.trim().isEmpty) {
      _nameController.text = match.name;
    }
    if (match != null &&
        (match.notes ?? '').isNotEmpty &&
        _notesController.text.trim().isEmpty) {
      _notesController.text = match.notes!;
    }
  }

  Future<void> _pickDueDate() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: l10n.selectDueDate,
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;

    setState(() => _saving = true);
    try {
      await DbHelper.instance.createDube(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        itemsDescription: _itemsController.text.trim(),
        totalAmount: amount,
        dueDate: _dueDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).couldNotSave('$error')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final hasOverdue = (_reliabilityStats?.overdueDebtsCount ?? 0) > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recordDebt),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Text(
                l10n.customer,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: l10n.nameHint,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.nameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  hintText: l10n.phoneHint,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                onChanged: _lookupCustomer,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.phoneRequired;
                  }
                  if (value.trim().length < 7) {
                    return l10n.phoneTooShort;
                  }
                  return null;
                },
              ),
              if (_existingCustomer != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: hasOverdue
                        ? scheme.errorContainer.withValues(alpha: 0.75)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasOverdue
                          ? scheme.error
                          : const Color(0xFFA5D6A7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            hasOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.verified_outlined,
                            size: 18,
                            color: hasOverdue
                                ? scheme.error
                                : const Color(0xFF1B5E20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.existingCustomerNamed(
                                _existingCustomer!.name,
                              ),
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: hasOverdue
                                    ? scheme.onErrorContainer
                                    : const Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_reliabilityStats != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.quickSummaryFor(_reliabilityStats!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: hasOverdue
                                ? scheme.error
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                l10n.dubeDetails,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _itemsController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: l10n.itemDetails,
                  hintText: l10n.itemHint,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.shopping_basket_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.itemsRequired;
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
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.amountEtb,
                  hintText: l10n.amountHint,
                  prefixIcon: const Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final parsed = double.tryParse((value ?? '').trim());
                  if (parsed == null) return l10n.amountInvalid;
                  if (parsed <= 0) return l10n.amountMustBePositive;
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
                title: Text(l10n.dueDate),
                subtitle: Text(formatDate(_dueDate)),
                trailing: const Icon(Icons.chevron_right),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.notesOptional,
                  hintText: l10n.notesHint,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? l10n.saving : l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
