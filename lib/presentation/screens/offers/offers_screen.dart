import 'package:flutter/material.dart';
import 'offer_inbox_screen.dart';
import 'my_sent_offers_screen.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Teklifler"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Verdiğim Teklifler"),
              Tab(text: "Aldığım Teklifler"),
            ],
          ),
        ),

        /// Burada const yok
        body: TabBarView(
          children: [
            MySentOffersScreen(),
            OfferInboxScreen(),
          ],
        ),
      ),
    );
  }
}
