import 'package:flutter/material.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController();

  static const List<Locale> supportedLocales = [Locale('tr')];

  Locale _locale = const Locale('tr');

  Locale get locale => _locale;
  Future<void> load() async {}

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'tr' || _locale.languageCode == 'tr') {
      return;
    }

    _locale = const Locale('tr');
    notifyListeners();
  }
}
