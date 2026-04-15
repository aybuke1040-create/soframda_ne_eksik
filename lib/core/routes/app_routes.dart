import 'package:flutter/material.dart';

import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/requests/create_request_screen.dart';
import '../../presentation/screens/ready_to_serve/ready_to_serve_screen.dart';

class AppRoutes {
  static const home = "/";
  static const createRequest = "/create-request";
  static const readyFoods = "/ready-foods";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case createRequest:
        return MaterialPageRoute(
          builder: (_) => const CreateRequestScreen(),
        );

      case readyFoods:
        return MaterialPageRoute(
          builder: (_) => const ReadyToServeScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route bulunamadı")),
          ),
        );
    }
  }
}
