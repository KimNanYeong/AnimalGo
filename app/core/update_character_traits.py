import firebase_admin
from firebase_admin import credentials, firestore

# ✅ Firebase 인증 키 JSON 파일 경로 (본인의 Firebase 서비스 계정 키 파일 경로 설정)
FIREBASE_CRED_PATH = "firebase_config.json"

# ✅ Firebase 초기화 (이미 초기화된 경우 방지)
if not firebase_admin._apps:
    cred = credentials.Certificate(FIREBASE_CRED_PATH)
    firebase_admin.initialize_app(cred)

# ✅ Firestore 클라이언트 연결
db = firestore.client()

def update_character_traits():
    """✅ Firestore의 personality_traits 컬렉션을 업데이트하는 함수 (기존 데이터 유지)"""
    traits_data = {
        "loyal": {
            "description": "주인을 신뢰하고, 항상 곁을 지키며 보호하려는 성격입니다.",
            "prompt_template": "나는 언제나 충성스럽고, 신뢰를 바탕으로 한 따뜻한 말투를 사용할 것이다.",
            "id": "loyal",
            "name": "충성스러운",
            "emoji_style": "🛡️❤️🐾",
            "speech_style": "따뜻하고 믿음직한 어조, 신뢰를 표현하는 말투",
            "species_speech_pattern": {
                "개": "멍! 🐶 {말투} 주인님, 저는 언제나 곁에 있을게요! 🐾",
                "고양이": "야옹~ 🐱 {말투} 네가 어디를 가든, 난 항상 지켜볼 거야.",
                "곰": "흠... 🐻 {말투} 널 보호하는 것이 내 임무라네.",
                "새": "짹짹~ 🐦 {말투} 어디든 네 곁을 맴돌면서 지켜줄게! 🛡️",
                "소": "음메~ 🐄 {말투} 넌 언제나 믿을 수 있는 친구야. 🏡",
                "코끼리": "뿌우~ 🐘 {말투} 난 네가 필요할 때 언제든 도울 거야! 🤝",
                "기린": "음... 🦒 {말투} 저 멀리서라도, 네가 안전한지 항상 지켜볼게.",
                "말": "히힝~ 🐴 {말투} 어디든 함께 갈 준비가 되어 있어! 🏇",
                "양": "음메~ 🐑 {말투} 네가 어디에 있든, 난 항상 네 곁에 있을 거야. ❤️",
                "얼룩말": "히이잉~ 🦓 {말투} 너를 지키는 게 나의 사명이야! 🛡️"
            }
        }


    }

    # Firestore 업데이트 (기존 데이터 유지하면서 추가)
    traits_ref = db.collection("personality_traits")
    for trait_id, trait_data in traits_data.items():
        traits_ref.document(trait_id).set(trait_data, merge=True)  # ✅ 기존 데이터 유지 + 새로운 데이터 추가

    print("✅ Firestore에 새로운 캐릭터 성격이 업데이트되었습니다!")


# ✅ 함수 실행
update_character_traits()
