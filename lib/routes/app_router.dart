import 'package:animalgo/screens/login/LoginScreen.dart';
import 'package:flutter/material.dart';
import '../screens/home/HomeScreen.dart';
import '../screens/chat/ChatListScreen.dart'; // ✅ 추가
import '../screens/chat/ChatRoomScreen.dart';

class AppRouter {
  static const String home = "/";
  static const String create = "/create";
  static const String chatList = '/chatList'; // ✅ 추가
  static const String chatRoom = '/chatRoom';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?; // ✅ Null Safety 적용
    print(settings.name);
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
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case '/chatRoom':
        return MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            friendName: args != null && args.containsKey('friendName') ? args['friendName']! : "알 수 없음", // ✅ Null 체크 후 사용
            initialMessages: args != null && args.containsKey('initialMessages') ? args['initialMessages']! : [],
            onMessageSent: (newMessage, newTime) {
              // ✅ 채팅 리스트 업데이트 로직 추가 가능
            },
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('404: Page not found')),
          ),
        );
    }
  }

  
}