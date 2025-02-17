import 'package:flutter/material.dart';
import '../character/CharacterScreen.dart';

class FriendInfoPopup extends StatelessWidget {
  final String friendName;
  final String friendImage;
  final String friendId;

  const FriendInfoPopup({
    Key? key,
    required this.friendName,
    required this.friendImage,
    required this.friendId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // 화면 너비
    return GestureDetector(
      onTap: () {
        // 바깥쪽 클릭 시 팝업 닫기
        Navigator.pop(context);
      },
      child: Container(
        color: Colors.transparent, // 배경을 투명하게 처리
        child: Center(
          child: GestureDetector(
            onTap: () {
              // 내부 영역 클릭 시 팝업 닫히지 않도록 아무 동작도 하지 않음
            },
            child: Material(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white, // 팝업의 배경은 흰색
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 이미지가 동그랗게 보이도록 처리
                    ClipOval(
                      child: Image.network(
                        "http://122.46.89.124:7000/image/show_image?character_id=${friendId}",
                        width: screenWidth * 0.5, // 화면 너비의 40%로 크기 설정
                        height: screenWidth * 0.5, // 화면 너비의 40%로 크기 설정
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 20),
                    // 닉네임
                    Text(
                      friendName,
                      style: TextStyle(
                        fontSize: screenWidth * 0.07, // 화면 너비의 7%로 글자 크기 설정
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    // 채팅하기 버튼과 상세보기 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // 채팅하기 버튼 동작 추가
                            print('채팅하기 버튼 눌림');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: Size(screenWidth * 0.35, 50), // 화면 너비의 35%로 버튼 크기 설정
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            '채팅하기',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05, // 화면 너비의 4%로 글자 크기 설정
                              color: Colors.white
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // 상세보기 버튼 동작 추가
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CharacterScreen()));
                            print('상세보기 버튼 눌림');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            minimumSize: Size(screenWidth * 0.35, 50), // 화면 너비의 35%로 버튼 크기 설정
                            padding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: Text(
                            '상세보기',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05, // 화면 너비의 4%로 글자 크기 설정
                              color: Colors.white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
