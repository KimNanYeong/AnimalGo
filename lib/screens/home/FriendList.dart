// friend_list.dart
import 'package:flutter/material.dart';
import 'FriendInfoPopup.dart'; // 팝업 모듈 임포트
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FriendList extends StatelessWidget {
  final List<Map<String, dynamic>> friends;

  const FriendList({Key? key, required this.friends}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double borderRadiusValue = 10.0;
    return Container(
      color: Colors.white, // 리스트 전체 컨테이너의 배경색 지정
      child: friends.isEmpty
          ? Center(
              child: Text(
                "등록된 친구가 없어요\n🥲\n카메라로 찍어보세요",
                style: TextStyle(fontSize: 18, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 16.0),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderRadiusValue),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(borderRadiusValue),
                      splashColor: Colors.grey[300],
                      highlightColor: Colors.grey[200],
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return FriendInfoPopup(
                              nickname: friend["nickname"]!,
                              // friendImage: friend["image"]!,
                              character_id : friend['character_id']
                            );
                          },
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          // backgroundImage: AssetImage(friend["image"]!),
                          backgroundImage: NetworkImage("${dotenv.env['SERVER_URL']}/image/show_image?character_id=${friend['character_id']}"),
                          radius: 25,
                        ),
                        title: Text(
                          friend["nickname"]!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
