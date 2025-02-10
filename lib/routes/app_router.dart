import 'package:flutter/material.dart';
import '../screens/home/HomeScreen.dart';
import '../screens/login/LoginScreen.dart';

class AppRouter {
  static const String home = "/";
  static const String create = "/create";
  static const String chat = "/chat";
  static const String login = "/login";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

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