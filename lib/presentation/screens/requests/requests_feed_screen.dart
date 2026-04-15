import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestsFeedScreen extends StatelessWidget {
  const RequestsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ben Yaparım"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("requests")
            .where("type", isEqualTo: "food_request")
            .where("status", isEqualTo: "open")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              /// kendi ilanını gösterme
              if (data["ownerId"] == FirebaseAuth.instance.currentUser!.uid) {
                return const SizedBox();
              }

              return ListTile(
                title: Text(data["title"] ?? ""),
                subtitle: Text(data["quantity"] ?? ""),
              );
            },
          );
        },
      ),
    );
  }
}
