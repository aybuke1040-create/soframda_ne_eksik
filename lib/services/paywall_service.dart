import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/buy_credits_screen.dart';
import 'credit_service.dart';

class PaywallService {
  static Future<bool> checkAndExecute({
    required BuildContext context,
    required int requiredCredits,
    required Future<void> Function() onSuccess,
  }) async {
    final creditService = CreditService();
    final credits = await creditService.getUserCredits();

    if (credits < requiredCredits) {
      showInsufficientCreditsSheet(
        context,
        title: 'Kredin şu an yeterli değil',
        message:
            'Devam etmek için kredi satın alabilir, sonra işlemini kolayca tamamlayabilirsin.',
      );
      return false;
    }

    await onSuccess();
    return true;
  }

  static void showInsufficientCreditsSheet(
    BuildContext context, {
    String title = 'Kredin şu an yeterli değil',
    String message =
        'Devam etmek için kredi satın alabilir, sonra işlemini kolayca tamamlayabilirsin.',
    String buttonLabel = 'Kredi Satın Al',
    String highlight = 'Kredi paketleri',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFD88912),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAF2),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFF2DFC2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        highlight,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF5E3A16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _quickPackButton(context, '50 Kredi\n49,99 TL'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _quickPackButton(context, '120 Kredi\n79,99 TL'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _quickPackButton(context, '300 Kredi\n149,99 TL'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BuyCreditsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0A329),
                      foregroundColor: const Color(0xFF3A1D07),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Şimdilik Vazgeç'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _quickPackButton(BuildContext context, String label) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BuyCreditsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF6EEE2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8D2AF)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF7A4B12),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
