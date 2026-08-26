import 'package:flutter/material.dart';

import 'package:dube/l10n/app_localizations.dart';
import 'package:dube/l10n/currency_controller.dart';

Future<void> showCurrencyPickerDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final current = CurrencyController.instance.currentSymbol;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.payments_outlined),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.selectCurrency)),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in CurrencyController.presets)
                  _CurrencyTile(
                    symbol: item['symbol']!,
                    label: item['label']!,
                    sublabel: item['sublabel']!,
                    isSelected: current == item['symbol'],
                    onTap: () async {
                      Navigator.of(dialogContext).pop();
                      await CurrencyController.instance.setCurrency(item['symbol']!);
                    },
                  ),
                const Divider(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    radius: 18,
                    child: Icon(Icons.edit, size: 18),
                  ),
                  title: Text(
                    l10n.customCurrency,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    Navigator.of(dialogContext).pop();
                    _showCustomCurrencyDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({
    required this.symbol,
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  final String symbol;
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isSelected
            ? scheme.primaryContainer.withValues(alpha: 0.6)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? scheme.primary
                        : scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    symbol,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isSelected ? scheme.onPrimary : scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      Text(
                        sublabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: scheme.primary)
                else
                  Icon(Icons.radio_button_unchecked, color: scheme.outlineVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showCustomCurrencyDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(
    text: CurrencyController.instance.currentSymbol,
  );

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.customCurrency),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.enterCurrencyHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 8,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'e.g. USD, KSh, ብር, FCFA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                await CurrencyController.instance.setCurrency(text);
              }
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(l10n.save),
          ),
        ],
      );
    },
  );
}
