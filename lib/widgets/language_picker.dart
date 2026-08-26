import 'package:flutter/material.dart';

import 'package:dube/l10n/app_localizations.dart';
import 'package:dube/l10n/locale_controller.dart';

class LanguageOption {
  const LanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.badge,
  });

  final String code;
  final String nativeName;
  final String englishName;
  final String badge;
}

const List<LanguageOption> kLanguageOptions = [
  LanguageOption(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    badge: 'EN',
  ),
  LanguageOption(
    code: 'am',
    nativeName: 'አማርኛ',
    englishName: 'Amharic',
    badge: 'አማ',
  ),
  LanguageOption(
    code: 'om',
    nativeName: 'Afaan Oromoo',
    englishName: 'Oromo',
    badge: 'OM',
  ),
];

Future<void> showLanguagePickerDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final selected = LocaleController.instance.locale?.languageCode;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.selectLanguage),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in kLanguageOptions)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LanguageOptionTile(
                  option: option,
                  selected: selected == option.code,
                  onTap: () async {
                    Navigator.of(dialogContext).pop();
                    await LocaleController.instance.setLocale(
                      Locale(option.code, ''),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}

class LanguageOptionTile extends StatelessWidget {
  const LanguageOptionTile({
    super.key,
    required this.option,
    required this.onTap,
    this.selected = false,
    this.prominent = false,
  });

  final LanguageOption option;
  final VoidCallback onTap;
  final bool selected;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: prominent ? 18 : 12,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: prominent ? 24 : 20,
                backgroundColor: selected
                    ? scheme.primary
                    : scheme.primary.withValues(alpha: 0.12),
                foregroundColor:
                    selected ? scheme.onPrimary : scheme.primary,
                child: Text(
                  option.badge,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? scheme.onPrimary : scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  option.nativeName,
                  style: (prominent
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.titleMedium)
                      ?.copyWith(
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? scheme.primary : scheme.onSurface,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: scheme.primary)
              else
                Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
