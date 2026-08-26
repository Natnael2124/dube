import 'package:flutter/material.dart';

import 'package:dube/database/db_helper.dart';
import 'package:dube/l10n/app_localizations.dart';
import 'package:dube/models/debt_record.dart';
import 'package:dube/models/debtor_entry.dart';
import 'package:dube/screens/add_debt_screen.dart';
import 'package:dube/screens/customer_detail_screen.dart';
import 'package:dube/screens/shop_notes_screen.dart';
import 'package:dube/utils/formatters.dart';
import 'package:dube/widgets/ad_banner_bar.dart';
import 'package:dube/widgets/currency_picker.dart';
import 'package:dube/widgets/language_picker.dart';

enum _DebtFilter { all, active, overdue, settled }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardStats _stats = DashboardStats.empty;
  List<DebtorEntry> _entries = const [];
  bool _loading = true;
  String? _error;
  String _query = '';
  _DebtFilter _filter = _DebtFilter.all;

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
      final stats = await DbHelper.instance.getDashboardStats();
      final entries = await DbHelper.instance.getAllDebtorEntries(
        includeSettled: true,
      );
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _entries = entries;
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

  List<DebtorEntry> get _visibleEntries {
    final q = _query.trim().toLowerCase();
    return _entries.where((entry) {
      final matchesFilter = switch (_filter) {
        _DebtFilter.all => true,
        _DebtFilter.active => entry.debt.status == DebtStatus.active,
        _DebtFilter.overdue => entry.debt.status == DebtStatus.overdue,
        _DebtFilter.settled => entry.debt.status == DebtStatus.settled,
      };
      if (!matchesFilter) return false;
      if (q.isEmpty) return true;
      return entry.customer.name.toLowerCase().contains(q) ||
          entry.customer.phone.toLowerCase().contains(q) ||
          entry.debt.itemsDescription.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openAddDebt() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AddDebtScreen(),
        fullscreenDialog: true,
      ),
    );
    if (created == true && mounted) {
      await _load();
    }
  }

  Future<void> _openCustomer(DebtorEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerDetailScreen(
          customerId: entry.customer.id!,
          focusDebtId: entry.debt.id,
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ድቤ  ·  Dube'),
                  const SizedBox(height: 2),
                  Text(
                    l10n.dashboard,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_note_rounded),
                  tooltip: l10n.dailyNotes,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShopNotesScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.payments_outlined),
                  tooltip: l10n.currency,
                  onPressed: () => showCurrencyPickerDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.language),
                  tooltip: l10n.selectLanguage,
                  onPressed: () => showLanguagePickerDialog(context),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              sliver: SliverToBoxAdapter(
                child: _SummaryRow(stats: _stats),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    SearchBar(
                      hintText: l10n.searchHint,
                      leading: const Icon(Icons.search),
                      elevation: const WidgetStatePropertyAll(0),
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text(l10n.all),
                              selected: _filter == _DebtFilter.all,
                              onSelected: (_) =>
                                  setState(() => _filter = _DebtFilter.all),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(l10n.active),
                              selected: _filter == _DebtFilter.active,
                              onSelected: (_) =>
                                  setState(() => _filter = _DebtFilter.active),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(l10n.overdue),
                              selected: _filter == _DebtFilter.overdue,
                              onSelected: (_) =>
                                  setState(() => _filter = _DebtFilter.overdue),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(l10n.paid),
                              selected: _filter == _DebtFilter.settled,
                              onSelected: (_) =>
                                  setState(() => _filter = _DebtFilter.settled),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _CenteredMessage(
                  icon: Icons.error_outline,
                  message: _error!,
                  actionLabel: l10n.retry,
                  onAction: _load,
                ),
              )
            else if (_visibleEntries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _CenteredMessage(
                  icon: Icons.storefront_outlined,
                  message: _entries.isEmpty
                      ? l10n.noRecordsYet
                      : _filter == _DebtFilter.settled
                          ? l10n.noPaidDebts
                          : l10n.noMatchingDebtors,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                sliver: SliverList.separated(
                  itemCount: _visibleEntries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = _visibleEntries[index];
                    return _DebtorCard(
                      entry: entry,
                      onTap: () => _openCustomer(entry),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDebt,
        icon: const Icon(Icons.add),
        label: Text(l10n.recordDebt),
      ),
      bottomNavigationBar: const SafeArea(
        child: AdBannerBar(),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tight = constraints.maxWidth < 520;
        final cards = [
          _SummaryCard(
            label: l10n.totalDue,
            value: formatEtbCompact(stats.totalActiveDube),
            icon: Icons.account_balance_wallet_outlined,
            tone: _SummaryTone.primary,
          ),
          _SummaryCard(
            label: l10n.overdueAccounts,
            value: '${stats.overdueAccounts}',
            icon: Icons.warning_amber_rounded,
            tone: _SummaryTone.danger,
          ),
          _SummaryCard(
            label: l10n.customers,
            value: '${stats.totalBorrowers}',
            icon: Icons.groups_outlined,
            tone: _SummaryTone.neutral,
          ),
        ];

        if (tight) {
          return Column(
            children: [
              cards[0],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: cards[1]),
                  const SizedBox(width: 8),
                  Expanded(child: cards[2]),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

enum _SummaryTone { primary, danger, neutral }

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tone,
  });

  final String label;
  final String value;
  final IconData icon;
  final _SummaryTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = switch (tone) {
      _SummaryTone.primary => (
          scheme.primaryContainer,
          scheme.onPrimaryContainer
        ),
      _SummaryTone.danger => (scheme.errorContainer, scheme.onErrorContainer),
      _SummaryTone.neutral => (
          scheme.surfaceContainerHighest,
          scheme.onSurface,
        ),
    };

    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: fg, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fg.withValues(alpha: 0.85),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtorCard extends StatelessWidget {
  const _DebtorCard({
    required this.entry,
    required this.onTap,
  });

  final DebtorEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final overdue = entry.debt.status == DebtStatus.overdue;
    final settled = entry.debt.isSettled;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: overdue
                        ? scheme.errorContainer
                        : settled
                            ? const Color(0xFFE8F5E9)
                            : scheme.primaryContainer,
                    foregroundColor: overdue
                        ? scheme.onErrorContainer
                        : settled
                            ? const Color(0xFF2E7D32)
                            : scheme.onPrimaryContainer,
                    child: settled
                        ? const Icon(Icons.check, size: 20)
                        : Text(
                            entry.customer.name.trim().isEmpty
                                ? '?'
                                : entry.customer.name.trim()[0].toUpperCase(),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.customer.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.customer.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatEtb(entry.debt.remainingBalance),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: overdue
                              ? scheme.error
                              : settled
                                  ? const Color(0xFF2E7D32)
                                  : scheme.primary,
                        ),
                      ),
                      if (settled)
                        Text(
                          '${l10n.totalPrefix} ${formatEtbCompact(entry.debt.totalAmount)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.debt.itemsDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    settled
                        ? Icons.check_circle_outline
                        : overdue
                            ? Icons.event_busy
                            : Icons.event_outlined,
                    size: 16,
                    color: settled
                        ? const Color(0xFF2E7D32)
                        : overdue
                            ? scheme.error
                            : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    settled
                        ? l10n.paid
                        : '${l10n.duePrefix} ${formatDateIso(entry.debt.dueDate)}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: settled
                          ? const Color(0xFF2E7D32)
                          : overdue
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                      fontWeight: (overdue || settled)
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (settled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        border: Border.all(color: const Color(0xFFA5D6A7)),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.paid,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF1B5E20),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    )
                  else if (overdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.overdue.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onErrorContainer,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.unpaid,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
