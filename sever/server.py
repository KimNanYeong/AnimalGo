from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import numpy as np
import cv2
from PIL import Image
import io
import base64
from ultralytics import YOLO
import logging
from fastapi.responses import JSONResponse
import traceback

# 로깅 설정 개선
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('server.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

app = FastAPI()

# CORS 설정 
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 전역 변수로 모델 선언
model = None

@app.on_event("startup")
async def startup_event():
    global model
    try:
        model = YOLO("animal.pt")
        logger.info("YOLO 모델 로드 완료")
    except Exception as e:
        logger.error(f"모델 로드 실패: {str(e)}")
        raise

@app.post("/segment/")
async def segment_image(file: UploadFile = File(...)):
    try:
        if not file:
            raise HTTPException(status_code=400, detail="파일이 없습니다")

        logger.info(f"이미지 수신 시작: {file.filename}")
        
        # 파일 크기 체크 (10MB 제한)
        contents = await file.read()
        if len(contents) > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="파일이 너무 큽니다")

        # 이미지 유효성 검사 및 변환
        try:
            image = Image.open(io.BytesIO(contents))
            if image.format not in ['JPEG', 'PNG']:
                raise HTTPException(status_code=400, detail="지원하지 않는 이미지 형식입니다")
            image = image.convert("RGB")
            image = np.array(image)
        except Exception as e:
            raise HTTPException(status_code=400, detail="잘못된 이미지 형식입니다")

        logger.info("이미지 변환 완료")

        # YOLO 모델로 세그멘테이션 수행 (Object Detection 제거)
        if model is None:
            raise HTTPException(status_code=500, detail="모델이 초기화되지 않았습니다")

        results = model.predict(image, task="segment")  # 세그멘테이션 전용 모드
        logger.info("세그멘테이션 완료")

        # 세그멘테이션 마스크만 추출
        if results[0].masks is None:
            raise HTTPException(status_code=500, detail="세그멘테이션 마스크를 생성할 수 없습니다.")

        # YOLOv8의 mask 데이터 가져오기 (0~1 사이 값)
        mask = results[0].masks.data[0].cpu().numpy()  # 첫 번째 객체의 마스크만 가져옴

        # 0~1 값을 0~255 범위로 변환하여 흑백 마스크 생성
        mask = (mask * 255).astype(np.uint8)

        # 원본 이미지와 크기 일치하도록 변환
        mask_resized = cv2.resize(mask, (image.shape[1], image.shape[0]))

        # 배경을 흰색으로 초기화
        background = np.full_like(image, (255, 255, 255), dtype=np.uint8)

        # 마스크를 이용해 원본 이미지에서 객체 부분만 추출
        segmented_image = np.where(mask_resized[:, :, None] > 128, image, background)

        # OpenCV로 RGB 변환 (Base64 인코딩을 위해)
        segmented_image = cv2.cvtColor(segmented_image, cv2.COLOR_RGB2BGR)

        # 이미지 압축 및 인코딩
        encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 90]
        _, buffer = cv2.imencode('.jpg', segmented_image, encode_param)
        encoded_image = base64.b64encode(buffer).decode('utf-8')

        logger.info("이미지 인코딩 완료")
        
        return JSONResponse(
            content={
                "status": "success",
                "image": encoded_image,
                "message": "세그멘테이션 완료"
            }
        )

    except HTTPException as he:
        logger.error(f"HTTP 에러: {str(he.detail)}")
        raise he
    except Exception as e:
        logger.error(f"예상치 못한 에러: {str(e)}\n{traceback.format_exc()}")
        raise HTTPException(status_code=500, detail="서버 내부 오류가 발생했습니다")



@app.get("/health")
async def health_check():
    if model is None:
        return JSONResponse(
            status_code=503,
            content={"status": "unhealthy", "detail": "모델이 로드되지 않았습니다"}
        )
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
