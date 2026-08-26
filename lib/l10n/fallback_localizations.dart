import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Oromo is a first-class app locale but is not shipped with Flutter's
/// Material/Cupertino localizations. Fall back to English widget strings
/// (date picker, dialog buttons, etc.) while app copy stays in Afaan Oromoo.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return DefaultMaterialLocalizations.load(const Locale('en', ''));
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return DefaultCupertinoLocalizations.load(const Locale('en', ''));
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
