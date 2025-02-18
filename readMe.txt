기본 환경설정 잡기

1.안드로이드 스튜디오에서 flutter 프로젝트 만들기

2.flutter 프로젝트에 android studio폴더안에 있는 것들 덮어쓰기

3.vscode같은 파이썬언어 가능한 프로그램에 sever폴더 넣기

4.sever단에서 패키지 설치하기(import 된 것들 찾아서 pip 설치)

실행방법

1.Fast API 이용하여 서버 여는 명령어(로컬에서 WIFI필요)
uvicorn server:app --host 0.0.0.0 --port 8000
터미널에서 위의 명령어 실행하기

2.안드로이드 스튜디오에서 앱을 추출하여 자신의 핸드폰에 설치하기



******주의****** 
@network_provide파일의 코드에서 final String _serverUrl = 'http://<자기 wifi어뎁터 ipv4주소 넣기>:8000';@