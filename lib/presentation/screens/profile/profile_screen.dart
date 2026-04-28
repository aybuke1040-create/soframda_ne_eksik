import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soframda_ne_eksik/presentation/screens/delivery/my_jobs_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/profile/edit_profile_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/review/create_review_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/settings/blocked_users_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/settings/community_terms_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/settings/settings_screen.dart';
import 'package:soframda_ne_eksik/services/action_feedback_service.dart';
import 'package:soframda_ne_eksik/services/moderation_service.dart';
import 'package:soframda_ne_eksik/services/request_completion_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
            child: Text('Kullan\u0131c\u0131 giri\u015f yapmam\u0131\u015f')),
      );
    }

    return UserProfileScreen(
      userId: user.uid,
      isCurrentUser: true,
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final String userId;
  final bool isCurrentUser;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.isCurrentUser = false,
  });

  Future<String?> _pickModerationReason(
    BuildContext context, {
    required String title,
  }) async {
    const reasons = <String>[
      'Hakaret veya taciz',
      'Uygunsuz icerik',
      'Spam veya dolandiricilik',
      'Tehdit veya guvensiz davranis',
      'Diger',
    ];

    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ...reasons.map((reason) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(reason),
                    onTap: () => Navigator.pop(sheetContext, reason),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _reportUser(
    BuildContext context,
    String targetName,
  ) async {
    final reason = await _pickModerationReason(
      context,
      title: 'Bu kullaniciyi neden sikayet etmek istiyorsun?',
    );
    if (reason == null) {
      return;
    }

    await ModerationService().reportUser(
      targetUserId: userId,
      reason: reason,
    );

    if (!context.mounted) {
      return;
    }

    await ActionFeedbackService.show(
      context,
      title: 'Sikayet alindi',
      message:
          '$targetName hakkindaki bildirimini aldik. Icerik 24 saat icinde incelenecek.',
      icon: Icons.flag_outlined,
    );
  }

  Future<void> _blockUser(
    BuildContext context,
    String targetName,
  ) async {
    final reason = await _pickModerationReason(
      context,
      title: 'Bu kullaniciyi neden engellemek istiyorsun?',
    );
    if (reason == null) {
      return;
    }

    await ModerationService().blockUser(
      targetUserId: userId,
      targetName: targetName,
    );

    if (!context.mounted) {
      return;
    }

    await ActionFeedbackService.show(
      context,
      title: 'Kullanici engellendi',
      message:
          '$targetName artik ilanlarinda, mesaj listende ve akisinda gosterilmeyecek.',
      icon: Icons.block_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? 'Profil' : 'Kullan\u0131c\u0131 Profili'),
        actions: isCurrentUser
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final name = data?['name'] ?? 'Kullan\u0131c\u0131';
          final photo = data?['photoUrl'] ?? '';
          final rating = (data?['ratingAverage'] ?? 0).toDouble();
          final orders = data?['completedOrders'] ?? 0;

          return StreamBuilder<Set<String>>(
            stream: ModerationService().watchBlockedUserIds(),
            builder: (context, blockedSnapshot) {
              final blockedUserIds = blockedSnapshot.data ?? const <String>{};
              final isBlocked = blockedUserIds.contains(userId);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: photo.toString().isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : Image.network(
                            photo,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, size: 50),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('followingIds', arrayContains: userId)
                      .snapshots(),
                  builder: (context, followerSnapshot) {
                    final followerCount =
                        followerSnapshot.data?.docs.length ?? 0;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statItem('\u0130\u015f', orders),
                        _statItem('Puan', rating.toStringAsFixed(1)),
                        _statItem('Takip\u00e7i', followerCount),
                      ],
                    );
                  },
                ),
                if (!isCurrentUser &&
                    currentUserId != null &&
                    currentUserId != userId) ...[
                  const SizedBox(height: 20),
                  _FollowButton(
                    currentUserId: currentUserId,
                    targetUserId: userId,
                    targetName: name,
                    targetPhoto: photo,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserListingsScreen(
                            userId: userId,
                            title: '$name ilanlar\u0131',
                          ),
                        ),
                      );
                    },
                    child: const Text('\u0130lanlar\u0131n\u0131 G\u00f6r'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _reportUser(context, name),
                    icon: const Icon(Icons.flag_outlined),
                    label: const Text('Kullaniciyi Sikayet Et'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isBlocked ? Colors.grey.shade700 : Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isBlocked
                        ? null
                        : () => _blockUser(context, name),
                    icon: const Icon(Icons.block),
                    label: Text(
                      isBlocked ? 'Bu kullanici engelli' : 'Kullaniciyi Engelle',
                    ),
                  ),
                ],
                if (isCurrentUser) ...[
                  const SizedBox(height: 30),
                  _menuItem(
                    icon: Icons.people_alt_outlined,
                    title: 'Takip Ettiklerim',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FollowingScreen(),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.restaurant_menu,
                    title: '\u0130lanlar\u0131m',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserListingsScreen(
                            userId: userId,
                            title: 'İlanlarım',
                            isCurrentUserListings: true,
                          ),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.work,
                    title: 'Benim  Yaptıklarım',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyJobsScreen(),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.gavel_outlined,
                    title: 'Topluluk Kurallari',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CommunityTermsScreen(),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.block_outlined,
                    title: 'Engelledigim Kullanicilar',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BlockedUsersScreen(),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    icon: Icons.settings,
                    title: 'Ayarlar',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 30),
                const Text(
                  'Yorumlar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _ReviewsSection(userId: userId),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  static Widget _statItem(String title, dynamic value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        Text(title),
      ],
    );
  }

  static Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  final String currentUserId;
  final String targetUserId;
  final String targetName;
  final String targetPhoto;

  const _FollowButton({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
    required this.targetName,
    required this.targetPhoto,
  });

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    if (widget.currentUserId == widget.targetUserId) {
      return const SizedBox.shrink();
    }

    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId);

    return StreamBuilder<DocumentSnapshot>(
      stream: currentUserRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Takip bilgisi y\u00fcklenemedi.');
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final followingIds =
            List<String>.from(data?['followingIds'] as List? ?? const []);
        final followingUsers = List<Map<String, dynamic>>.from(
          (data?['followingUsers'] as List? ?? const []).map(
            (item) => Map<String, dynamic>.from(item as Map),
          ),
        );
        final isFollowing = followingIds.contains(widget.targetUserId);

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() {
                      _saving = true;
                    });

                    try {
                      if (isFollowing) {
                        await currentUserRef.update({
                          'followingIds': FieldValue.arrayRemove(
                            [widget.targetUserId],
                          ),
                          'followingUsers': followingUsers
                              .where(
                                (item) => item['userId'] != widget.targetUserId,
                              )
                              .toList(),
                        });
                      } else {
                        final updatedUsers = List<Map<String, dynamic>>.from(
                          followingUsers,
                        )..add({
                            'userId': widget.targetUserId,
                            'name': widget.targetName,
                            'photoUrl': widget.targetPhoto,
                          });

                        await currentUserRef.update({
                          'followingIds': FieldValue.arrayUnion(
                            [widget.targetUserId],
                          ),
                          'followingUsers': updatedUsers,
                        });
                      }

                      if (!context.mounted) {
                        return;
                      }

                      await ActionFeedbackService.show(
                        context,
                        title: isFollowing
                            ? 'Takip bırakıldı'
                            : 'Kullanıcı takip edildi',
                        message: isFollowing
                            ? 'Takip bırakıldı.'
                            : 'Kullanıcı takip edildi.',
                        icon: Icons.person_add_alt_1_rounded,
                      );
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      await ActionFeedbackService.show(
                        context,
                        title: 'Takip işlemi başarısız',
                        message: 'Takip işlemi başarısız: $e',
                        icon: Icons.error_outline_rounded,
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _saving = false;
                        });
                      }
                    }
                  },
            child: Text(
              _saving
                  ? 'Kaydediliyor...'
                  : (isFollowing ? 'Takibi B\u0131rak' : 'Takip Et'),
            ),
          ),
        );
      },
    );
  }
}

class FollowingScreen extends StatelessWidget {
  const FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Takip Ettiklerim')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userDoc = snapshot.data!.docs.isEmpty
              ? null
              : snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final followingUsers = List<Map<String, dynamic>>.from(
            (userDoc?['followingUsers'] as List? ?? const []).map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          );

          if (followingUsers.isEmpty) {
            return const Center(
                child: Text(
                    'Hen\u00fcz takip etti\u011fin kullan\u0131c\u0131 yok'));
          }

          return ListView.builder(
            itemCount: followingUsers.length,
            itemBuilder: (context, index) {
              final data = followingUsers[index];
              final followedUserId = data['userId'] ?? '';
              final photo = data['photoUrl'] ?? '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      photo.toString().isNotEmpty ? NetworkImage(photo) : null,
                  child: photo.toString().isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(data['name'] ?? 'Kullan\u0131c\u0131'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(userId: followedUserId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class UserListingsScreen extends StatelessWidget {
  final String userId;
  final String title;
  final bool isCurrentUserListings;

  UserListingsScreen({
    super.key,
    required this.userId,
    required this.title,
    this.isCurrentUserListings = false,
  });

  final RequestCompletionService _completionService =
      RequestCompletionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('ownerId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['requestType'] != 'recipe';
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('Hen\u00fcz ilan yok'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return _ProfilePreviewCard(
                title: data['title'] ?? '',
                imageUrl: data['imageUrl'] ?? '',
                onTap: () {
                  _showListingDetails(
                    context: context,
                    data: data,
                    requestId: docs[index].id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showListingDetails({
    required BuildContext context,
    required Map<String, dynamic> data,
    required String requestId,
  }) {
    final status = data['status'] ?? 'open';
    final acceptedUserId = data['acceptedUserId'] as String? ?? '';
    final ownerCompleted = data['ownerCompleted'] == true;
    final workerCompleted = data['workerCompleted'] == true;
    final reviewByOwner = data['reviewByOwner'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if ((data['description'] ?? '').toString().isNotEmpty)
                  Text(data['description']),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _listingInfo(
                      status == 'completed'
                          ? 'Tamamland\u0131'
                          : status == 'in_progress'
                              ? 'Devam ediyor'
                              : 'A\u00e7\u0131k',
                    ),
                    if (acceptedUserId.isNotEmpty)
                      _listingInfo('Teklif kabul edildi'),
                    if (status == 'in_progress')
                      _listingInfo(
                        ownerCompleted
                            ? 'Sen tamamland\u0131 dedin'
                            : 'Onay\u0131n bekleniyor',
                      ),
                    if (status == 'in_progress')
                      _listingInfo(
                        workerCompleted
                            ? 'Kar\u015f\u0131 taraf tamamland\u0131 dedi'
                            : 'Kar\u015f\u0131 taraf\u0131n onay\u0131 bekleniyor',
                      ),
                  ],
                ),
                if (isCurrentUserListings) ...[
                  const SizedBox(height: 16),
                  if (status == 'in_progress' && !ownerCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final result = await _completionService.markCompleted(
                            requestId: requestId,
                            currentUserId: userId,
                            isOwner: true,
                          );
                          if (!context.mounted) {
                            return;
                          }

                          if (result['completed'] == true &&
                              !reviewByOwner &&
                              acceptedUserId.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateReviewScreen(
                                  toUserId: acceptedUserId,
                                  requestId: requestId,
                                  isOwnerReview: true,
                                ),
                              ),
                            );
                            return;
                          }

                          await ActionFeedbackService.show(
                            context,
                            title: result['completed'] == true
                                ? 'İş tamamlandı'
                                : 'Onay bekleniyor',
                            message: result['completed'] == true
                                ? 'İş tamamlandı. Yorum ekranı açılıyor.'
                                : 'Karşı tarafın tamamlandı onayı bekleniyor.',
                            icon: Icons.check_circle_outline_rounded,
                          );
                        },
                        child: const Text('Tamamlandı De'),
                      ),
                    ),
                  if (status == 'completed' &&
                      !reviewByOwner &&
                      acceptedUserId.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateReviewScreen(
                                toUserId: acceptedUserId,
                                requestId: requestId,
                                isOwnerReview: true,
                              ),
                            ),
                          );
                        },
                        child: const Text('Yorum Yap ve Puanla'),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _listingInfo(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _ProfilePreviewCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _ProfilePreviewCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: imageUrl.toString().isEmpty
                    ? Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.inventory_2_outlined, size: 42),
                      )
                    : _buildImage(imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(imageUrl, fit: BoxFit.cover);
    }
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.inventory_2_outlined, size: 42),
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final String userId;

  const _ReviewsSection({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Hen\u00fcz yorum yok.');
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snapshot.data?.docs.toList() ?? [];
        final docs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['targetUserId'] == userId || data['toUserId'] == userId;
        }).toList();
        docs.sort((a, b) {
          final aTime = (a.data() as Map<String, dynamic>)['createdAt'];
          final bTime = (b.data() as Map<String, dynamic>)['createdAt'];
          final aMs = aTime is Timestamp ? aTime.millisecondsSinceEpoch : 0;
          final bMs = bTime is Timestamp ? bTime.millisecondsSinceEpoch : 0;
          return bMs.compareTo(aMs);
        });

        if (docs.isEmpty) {
          return const Text('Hen\u00fcz yorum yok.');
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final rating = (data['rating'] ?? 0).toDouble();
            final comment = data['comment'] ?? '';

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (comment.toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(comment),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
