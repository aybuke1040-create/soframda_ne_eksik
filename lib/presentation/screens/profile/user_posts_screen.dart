import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPostsScreen extends StatelessWidget {
  final String userId;

  const UserPostsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kullanıcının İlanları")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("requests")
            .where("ownerId", isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i];

              return ListTile(
                title: Text(data["title"]),
                subtitle: Text("${data["price"]}₺"),
              );
            },
          );
        },
      ),
    );
  }
}
