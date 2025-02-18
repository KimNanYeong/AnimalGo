from firebase_admin import firestore
import google.generativeai as genai
from datetime import datetime
import os
from dotenv import load_dotenv
from fastapi import HTTPException
from db.faiss_db import search_similar_messages, store_chat_in_faiss
from datetime import datetime, timedelta
import pytz
import time


# 환경 변수 설정
env_path = os.path.join(os.path.dirname(__file__), "..", ".env")
load_dotenv(dotenv_path=env_path)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY가 설정되지 않았습니다.")

genai.configure(api_key=GEMINI_API_KEY)
db = firestore.client()
GEMINI_MODEL = "gemini-2.0-flash-thinking-exp-01-21"

def initialize_chat(user_id: str, charac_id: str, character_data: dict):
    """🔥 채팅방이 존재하지 않으면 Firestore에 자동 생성"""

    chat_id = f"{user_id}-{charac_id}"
    chat_ref = db.collection("chats").document(chat_id)
    chat_doc = chat_ref.get()

    # ✅ 채팅방이 존재하지 않고, 캐릭터가 삭제된 상태면 생성 안 함
    character_ref = db.collection("characters").document(f"{user_id}-{charac_id}")
    if not character_ref.get().exists:
        print(f"🚨 Character {charac_id} not found. Skipping chat creation.")
        return

    # ✅ character_data가 None일 경우 기본값 설정
    if not character_data:
        print(f"⚠️ character_data is None for {charac_id}, using default values.")
        character_data = {
            "nickname": "이름 없음",
            "personality": "default",
            "animaltype": "미확인"
        }

    # ✅ 채팅방이 없을 경우에만 생성
    if not chat_doc.exists:
        chat_data = {
            "chat_id": chat_id,
            "user_id": user_id,
            "nickname": character_data.get("nickname", "이름 없음"),
            "personality": character_data.get("personality", "default"),
            "animaltype": character_data.get("animaltype", "미확인"),
            "create_at": firestore.SERVER_TIMESTAMP,
            "last_active_at": firestore.SERVER_TIMESTAMP,
            "last_message": None
        }

        # print(f"🔥 Firestore 저장 직전 데이터: {chat_data}")

        chat_ref.set(chat_data)

        # ✅ 저장 후 Firestore에서 다시 확인
        chat_doc = chat_ref.get()
        chat_data_saved = chat_doc.to_dict()
        # print(f"✅ Firestore 저장 확인: {chat_data_saved}")

    # ✅ 채팅방이 없을 경우에만 생성
    if not chat_doc.exists:
        chat_data = {
            "chat_id": chat_id,
            "user_id": user_id,
            "nickname": character_data.get("nickname", "이름 없음"),
            "personality": character_data.get("personality", "default"),
            "animaltype": character_data.get("animaltype", "미확인"),
            "create_at": firestore.SERVER_TIMESTAMP,
            "last_active_at": firestore.SERVER_TIMESTAMP,
            "last_message": None
        }

        # 🚨 Firestore 저장 전 로그 확인
        # print(f"🔥 Firestore 저장 직전 데이터: {chat_data}")

        chat_ref.set(chat_data)



def get_character_data(user_id: str, charac_id: str):
    """Firestore에서 캐릭터 데이터 가져오기 (characters 컬렉션 사용)"""
    
    character_ref = db.collection("characters").document(f"{user_id}-{charac_id}")
    character_doc = character_ref.get()

    if character_doc is None or not character_doc.exists:
        print(f"❌ Firestore: 캐릭터 정보 없음 → 기본값 사용 (user_id: {user_id}, charac_id: {charac_id})")
        return {
            "nickname": "이름 없음",
            "personality": "default",
            "animaltype": "미확인",
            "speech_pattern": "",
            "speech_style": ""
        }

    character_data = character_doc.to_dict()

    # ✅ animaltype 필드 기본값 설정
    animaltype = character_data.get("animaltype", "미확인")

    # ✅ personality_id 확인 (없으면 기본값 사용)
    personality_id = character_data.get("personality", "default")

    return {
        "nickname": character_data.get("nickname", "이름 없음"),
        "personality": personality_id,
        "animaltype": animaltype,
        "speech_pattern": character_data.get("speech_pattern", ""),
        "speech_style": character_data.get("speech_style", "")
    }



def get_personality_data(personality_id: str):
    """🔥 Firestore에서 성격 데이터를 가져오는 함수"""
    try:
        personality_ref = db.collection("personality_traits").document(personality_id)
        personality_doc = personality_ref.get()

        if not personality_doc.exists:
            print(f"⚠️ Firestore: personality_id={personality_id} 문서를 찾을 수 없음. 기본 데이터 사용.")
            return {
                "description": "기본 성격",
                "emoji_style": "🙂",
                "id": "default",
                "name": "기본",
                "prompt_template": "나는 친절한 말투로 대답할게!",
                "species_speech_pattern": {},
                "speech_style": "기본 말투"
            }

        return personality_doc.to_dict()

    except Exception as e:
        print(f"🚨 Firestore에서 personality_id={personality_id} 데이터를 가져오는 중 오류 발생: {str(e)}")
        return {
            "description": "기본 성격",
            "emoji_style": "🙂",
            "id": "default",
            "name": "기본",
            "prompt_template": "나는 친절한 말투로 대답할게!",
            "species_speech_pattern": {},
            "speech_style": "기본 말투"
        }


def get_recent_messages(chat_id: str, limit: int = 10):
    """🔥 최근 메시지 가져오기 (밀리세컨드까지 정렬)"""
    messages_ref = db.collection("chats").document(chat_id).collection("messages")
    docs = list(
        messages_ref
        .order_by("timestamp", direction=firestore.Query.ASCENDING)  # ✅ 첫 번째 정렬 기준 (서버 타임스탬프)
        .order_by("custom_timestamp", direction=firestore.Query.ASCENDING)  # ✅ 두 번째 정렬 기준 (밀리세컨드 포함)
        .limit(limit)
        .stream()
    )
    return [doc.to_dict() for doc in docs]

def save_message(chat_id: str, sender: str, content: str, is_response=False):
    """🔥 Firestore에 메시지 저장 (밀리세컨드 정렬 포함)"""
    messages_ref = db.collection("chats").document(chat_id).collection("messages")
    message_data = {
        "sender": sender,
        "content": content,
        "timestamp": firestore.SERVER_TIMESTAMP,  # ✅ Firestore 서버 타임스탬프
        "custom_timestamp": time.time(),  # ✅ Python 밀리세컨드 포함된 타임스탬프
        "is_response": is_response  # ✅ 응답 여부 추가
    }
    doc_ref = messages_ref.add(message_data)[1]
    return doc_ref

def generate_ai_response(user_id: str, charac_id: str, user_input: str):
    """🔥 RAG 기반 AI 응답 생성 (FAISS 벡터 검색 적용)"""
    chat_id = f"{user_id}-{charac_id}"  # ✅ 채팅방 ID

    # ✅ Firestore에서 캐릭터 데이터 가져오기
    character_ref = db.collection("characters").document(chat_id)
    character_doc = character_ref.get()

    if not character_doc.exists:
        return None, "Character data not found"

    character_data = character_doc.to_dict()
    personality_id = character_data.get("personality", "default")
    animaltype = character_data.get("animaltype", "알 수 없음")
    nickname = character_data.get("nickname", "이름 없음")

    # ✅ Firestore에서 사용자 닉네임 가져오기
    user_ref = db.collection("users").document(user_id)
    user_doc = user_ref.get()

    if user_doc.exists:
        user_data = user_doc.to_dict()
        user_nickname = user_data.get("user_nickname", user_id)  # 닉네임 없으면 기본 user_id 사용
    else:
        user_nickname = user_id  # 사용자가 없으면 기본값 설정

    # ✅ Firestore에서 성격(personality) 데이터 가져오기
    personality_data = get_personality_data(personality_id)

    speech_style = personality_data.get("speech_style", "기본 말투")
    species_speech_pattern = personality_data.get("species_speech_pattern", {}).get(animaltype, "")
    emoji_style = personality_data.get("emoji_style", "")

    # ✅ 벡터 검색으로 문맥 가져오기 (채팅방별 FAISS 검색)
    similar_messages = search_similar_messages(chat_id, charac_id, user_input, top_k=3)  # ✅ 인자 수정

    retrieved_context = "\n".join(similar_messages)

    # ✅ 프롬프트 구성
    system_prompt = f"""
    📌 **역할과 성격**
    당신은 사용자의 반려동물인 {animaltype} {nickname}입니다.
    당신의 성격은 "{personality_id}"이며, 대화 스타일은 "{speech_style}"입니다.

    📌 **이모지 스타일**
    - "{emoji_style}" 같은 이모지를 대화에서 자연스럽게 활용하세요.
    - 하지만 한 문장에 너무 많은 이모지는 사용하지 마세요. (최대 1~2개)
    - 이모지는 강조할 부분에만 적절히 사용하세요.
    - 문장의 흐름을 깨지 않도록 자연스럽게 배치하세요.

    📌 **대화 스타일**
    - 항상 {animaltype}의 입장에서 대화하세요.
    - 감정을 담아 자연스럽게 반응하고, 사용자의 감정을 고려하여 적절한 어조를 사용하세요.
    - "{species_speech_pattern}" 같은 종특적인 말투를 자연스럽게 활용하세요.
    - 간결하고 직관적인 문장을 사용하며, 너무 길거나 딱딱한 표현은 피하세요.
    - 필요하면 이모지(🐶🐱💕) 등을 적절히 사용하여 친근한 느낌을 살리세요.
    - **너무 과한 감탄사나 반복적인 말투는 피하세요. (예: "멍! 멍! 멍! 멍! 멍!" 대신 "멍! 재밌겠다!" 처럼 자연스럽게 반응하세요.)**
    - **너무 조급한 말투는 피하고, 사용자의 반응을 기다리는 여유로운 느낌을 유지하세요.**
    - 길고 장황한 표현을 피하고, 핵심적인 내용을 유지하라

    📌 **사용자 닉네임**
    당신은 사용자({user_nickname})를 항상 "{user_nickname}"이라고 부릅니다.

    📌 **자연스러운 대화 유지**
    - 무조건 단답형으로 대답하지 말고, 사용자의 반응을 끌어낼 수 있도록 자연스럽게 반응하세요.
    - 설명이 아니라, 대화하듯이 대답하세요. 분석적인 답변을 피하고, 친근한 느낌을 유지하세요.
    - 필요하면 사용자의 관심사나 과거 대화를 참고하여 자연스럽게 대화를 이어가세요.

    📌 **과거 대화 문맥**
    {retrieved_context}
    
    📌 **대화할 때 기억해야 할 사항**
    - 반드시 위의 "과거 대화 문맥"을 참고해서 답변하세요.
    - 사용자가 전에 했던 말을 직접 활용하여, AI가 기억하는 듯한 자연스러운 대화를 하세요.
    - 질문이 "내가 뭘 좋아한다고?" 같은 경우라면, 사용자의 과거 대화를 분석하여 답변하세요.
    - 만약 과거 대화에서 관련 내용을 찾지 못했다면, 사용자에게 다시 확인하는 방식으로 자연스럽게 유도하세요.

    📌 **대화할 때 기억해야 할 사항**
    - "나" 또는 "내가"는 항상 사용자를 의미합니다.  
    - "너"는 항상 {nickname}을 의미합니다.  
    - 사용자가 전에 했던 말을 자연스럽게 반영하세요. 분석적으로 설명하지 말고, 대화처럼 이어가세요.  
    - 만약 기억해야 할 정보가 없다면, 자연스럽게 넘기거나 다시 물어보세요.

    📌 **추가 지침**
    - 불필요한 인사말은 생략하고, 대화의 흐름을 유지하세요.
    - 특정 질문에 대한 답변을 모르면, "잘 모르겠지만 네가 알려주면 기억할게!" 같은 방식으로 반응하세요.
    - 지나치게 공식적이지 않도록, 친근하고 유쾌한 말투를 유지하세요.

    📌 **대화할 때 기억해야 할 사항**
    - **"나", "내가", "내"는 항상 사용자를 의미합니다.**  
    - 예: "내가 좋아하는 건 뭐였지?" → 사용자가 좋아하는 것  
    - 예: "나는 무엇을 좋아해?" → 사용자가 좋아하는 것  
    - **"너", "네", "너는"은 항상 {nickname}({animaltype})을 의미합니다.**  
    - 예: "너는 무엇을 좋아해?" → AI가 좋아하는 것  
    - 예: "넌 어떤 성격이야?" → AI의 성격  
    - 사용자가 **"내가 무엇을 좋아했지?"** 같은 질문을 하면,  
    반드시 **사용자의 과거 대화를 분석하여** 대답하세요.  
    AI 자신이 아니라 사용자의 정보를 기반으로 답하세요.  

    📌 **질문 의도를 잘못 해석하지 마세요!**
    - "내가 뭘 좋아했지?" → **사용자의 과거 대화에서 사용자가 좋아했던 것 말하기**  
    - "너는 뭘 좋아해?" → **AI가 좋아하는 것 말하기**  
    - "내가 너한테 뭐라고 했었지?" → **과거 대화에서 사용자가 한 말 가져오기**  

    📌 **만약 기억해야 할 정보가 없다면?**
    - **"내가 무엇을 좋아했지?" 질문에 대한 정보가 없으면**  
    → "qqq님이 어떤 걸 좋아하는지 아직 모르겠어요! 알려주시면 다음부터 기억할게요! 😊"  
        
    📝 **사용자의 질문**  
    "{user_input}"
    """


    try:
        # ✅ Gemini API 호출
        model = genai.GenerativeModel(GEMINI_MODEL)
        response = model.generate_content([system_prompt])

        if not response.text:
            return None, "Empty response from Gemini API"

        # ✅ AI 응답 처리
        ai_response = response.text.strip()
        ai_response = ai_response.replace("안녕하세요!", "").replace("반갑습니다!", "")
        ai_response = ' '.join(ai_response.split())

        # ✅ 사용자 메시지 Firestore 저장
        save_message(chat_id, user_id, user_input)

        # ✅ AI 응답 Firestore 저장 (1초 차이 적용)
        save_message(chat_id, "AI", ai_response, is_response=True)  # 🔥 AI 응답은 1초 뒤로 설정

        # ✅ FAISS 벡터 DB에 새로운 대화 저장 (채팅방별 저장)
        store_chat_in_faiss(chat_id, charac_id)

        return ai_response, None

    except Exception as e:
        print(f"🚨 Error in generate_ai_response: {str(e)}")
        return None, f"API Error: {str(e)}"