import 'package:flutter/material.dart';
import '../screens/home/HomeScreen.dart';

class AppRouter {
  static const String home = "/";
  static const String create = "/create";
  static const String chat = "/chat";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      // case about:
      //   return MaterialPageRoute(builder: (_) => AboutScreen());
      // case profile:
      //   final args = settings.arguments as String?;
      //   return MaterialPageRoute(
      //     builder: (_) => ProfileScreen(userId: args ?? 'No ID'),
      //   );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('404: Page not found')),
          ),
        );
    }
  }

  
}