import 'package:flutter/material.dart';

import 'package:soframda_ne_eksik/presentation/screens/requests/all_requests_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/messages_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/profile/profile_screen.dart';

import '../chat/chat_list_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/home/home_screen.dart';
import 'package:soframda_ne_eksik/presentation/screens/ready_to_serve/ready_to_serve_screen.dart';
import '../requests/open_requests_screen.dart';
import '../notifications/notifications_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ReadyToServeScreen(),
    OpenRequestsScreen(),
    ChatListScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact(); // sende zaten var
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Alerts"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
