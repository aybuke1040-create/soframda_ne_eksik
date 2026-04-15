import 'package:cloud_functions/cloud_functions.dart';

class CreditActions {
  static final _functions = FirebaseFunctions.instance;

  static Future<void> useCredits(int amount) async {
    final callable = _functions.httpsCallable('useCredits');

    await callable.call({
      'amount': amount,
    });
  }

  static Future<void> addCredits(int amount) async {
    final callable = _functions.httpsCallable('addCredits');

    await callable.call({
      'amount': amount,
    });
  }
}
