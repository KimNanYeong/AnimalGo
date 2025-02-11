import 'package:flutter/material.dart';

class Topbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton; // 뒤로가기 버튼 표시 여부

  const Topbar({
    Key? key,
    required this.title,
    this.showBackButton = false, // 기본값은 false (아이콘 미노출)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      elevation: 0,
      leadingWidth: showBackButton ? null : 0, // leading이 없을 때 공간 제거
      leading: showBackButton // showBackButton이 true이면 뒤로가기 아이콘 노출
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context); // 이전 화면으로 이동
              },
            )
          : Container(), // false면 leading을 null로 설정하여 아이콘 미노출
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.black),
          onPressed: () {
            // 알림 버튼 동작 추가
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // AppBar의 기본 높이
}
