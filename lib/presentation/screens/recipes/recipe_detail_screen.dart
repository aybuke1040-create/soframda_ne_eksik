import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/requests/create_request_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(recipeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text('Tarif bulunamadı.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final title = data['title'] as String? ?? '';
          final description = data['description'] as String? ?? '';
          final ingredients = data['ingredients'] as String? ?? '';
          final instructions = data['instructions'] as String? ?? '';
          final ownerName = data['ownerName'] as String? ?? '';
          final imageUrl = data['imageUrl'] as String? ?? '';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                title: const Text('Tarif'),
                flexibleSpace: FlexibleSpaceBar(
                  background: imageUrl.isEmpty
                      ? Container(
                          color: Colors.orange.shade50,
                          child: const Icon(Icons.menu_book, size: 72),
                        )
                      : Image.network(imageUrl, fit: BoxFit.cover),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (ownerName.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Tarifi ekleyen: $ownerName',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                      if (description.trim().isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          description,
                          style: const TextStyle(height: 1.5),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Text(
                        'Malzemeler',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _sectionBox(
                        ingredients.trim().isEmpty
                            ? 'Malzeme bilgisi eklenmemiş.'
                            : ingredients,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Yapılış',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _sectionBox(
                        instructions.trim().isEmpty
                            ? 'Hazırlık adımı eklenmemiş.'
                            : instructions,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateRequestScreen(
                                  presetTitle: '$title istiyorum',
                                  presetDescription:
                                      'Bu tariften istiyorum. Kim yapabilir?\n\nTarif: $title\n$description',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.local_offer_outlined),
                          label: const Text('Bu Tariften İstiyorum'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _sectionBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: const TextStyle(height: 1.5),
      ),
    );
  }
}
