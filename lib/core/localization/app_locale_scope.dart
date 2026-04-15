import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/core/localization/app_locale_controller.dart';

class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  const AppLocaleScope({
    super.key,
    required AppLocaleController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static AppLocaleController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope bulunamadi.');
    return scope!.notifier!;
  }
}

extension AppLocaleTexts on BuildContext {
  AppLocaleController get appLocale => AppLocaleScope.of(this);

  String t(String tr, String en) {
    return tr;
  }
}
