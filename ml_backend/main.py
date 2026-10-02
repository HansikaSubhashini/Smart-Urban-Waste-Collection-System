from pathlib import Path
import math
import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="Waste Truck ETA API")
# Path to the real model
model_path = Path(__file__).parent / "models" / "eta_model_v1.joblib"
model = joblib.load(model_path) if model_path.exists() else None

class ETAInput(BaseModel):
    distance_to_target_km: float = Field(ge=0, allow_inf_nan=False)
    current_speed_kmh: float = Field(ge=0, allow_inf_nan=False)
    hour: int = Field(ge=0, le=23)
    day_of_week: int = Field(ge=0, le=6)
    is_weekend: int = Field(ge=0, le=1)
    road_type: str = Field(pattern="^(main_road|mixed|narrow_road|unknown)$")

FEATURE_COLUMNS = [
    "distance_to_target_km",
    "current_speed_kmh",
    "hour",
    "day_of_week",
    "is_weekend",
    "is_peak_hour",
    "road_type_encoded",
]
ROAD_TYPE_MAP = {"main_road": 0, "mixed": 1, "narrow_road": 2, "unknown": 1}

@app.get("/health")
def health():
    return {"status": "ok", "model_loaded": model is not None}

@app.post("/predict")
def predict(data: ETAInput):
    if model is None:
        raise HTTPException(503, "Model not loaded. Please run the notebook first.")

    df = pd.DataFrame([data.model_dump()])
    df["is_peak_hour"] = df["hour"].isin([7, 8, 12, 13, 16]).astype(int)
    df["road_type_encoded"] = df["road_type"].map(ROAD_TYPE_MAP).fillna(1).astype(int)
    
    eta = float(model.predict(df[FEATURE_COLUMNS])[0])
    if not math.isfinite(eta) or eta < 0:
        raise HTTPException(500, "Invalid model output")
    return {"eta_minutes": eta}
