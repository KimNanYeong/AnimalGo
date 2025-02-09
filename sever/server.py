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
        
        # 파일 크기 체크
        contents = await file.read()
        if len(contents) > 10 * 1024 * 1024:  # 10MB 제한
            raise HTTPException(status_code=400, detail="파일이 너무 큽니다")

        # 이미지 유효성 검사
        try:
            image = Image.open(io.BytesIO(contents))
            if image.format not in ['JPEG', 'PNG']:
                raise HTTPException(status_code=400, detail="지원하지 않는 이미지 형식입니다")
            image = image.convert("RGB")
            image = np.array(image)
        except Exception as e:
            raise HTTPException(status_code=400, detail="잘못된 이미지 형식입니다")

        logger.info("이미지 변환 완료")

        # YOLO 모델로 세그멘테이션 수행
        if model is None:
            raise HTTPException(status_code=500, detail="모델이 초기화되지 않았습니다")
        
        results = model.predict(image)
        logger.info("세그멘테이션 완료")

        # 결과 이미지 생성 및 최적화
        mask = results[0].plot()
        mask = cv2.cvtColor(mask, cv2.COLOR_BGR2RGB)
        
        # 이미지 압축 및 인코딩
        encode_param = [int(cv2.IMWRITE_JPEG_QUALITY), 90]
        _, buffer = cv2.imencode('.jpg', mask, encode_param)
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