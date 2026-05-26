import logging

from contextlib import asynccontextmanager

from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware

from app.data_loader import fetch_reports
from app.inference import process_report
from app.risk_predictor import analyze_risk
from app.scheduler import create_scheduler, run_ml_cycle
from app.zone_classifier import classify_zone

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


# ──────────────────────────────────────────────────────────────────────────────
#  Lifespan — arranca y apaga el scheduler con la app
# ──────────────────────────────────────────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    scheduler = create_scheduler()
    scheduler.start()
    logger.info("Scheduler ML iniciado (cada %d min)", 5)

    # Corre un ciclo inmediato al arrancar para que el backend
    # tenga datos desde el primer segundo
    await run_ml_cycle()

    yield  # ← la app vive aquí

    scheduler.shutdown(wait=False)
    logger.info("Scheduler ML detenido")


app = FastAPI(title="Traza ML Service", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ──────────────────────────────────────────────────────────────────────────────
#  Schema de entrada
# ──────────────────────────────────────────────────────────────────────────────

class Report(BaseModel):
    category: str
    description: str
    latitude: float
    longitude: float
    timestamp: str


# ──────────────────────────────────────────────────────────────────────────────
#  Endpoints existentes (sin cambios de contrato)
# ──────────────────────────────────────────────────────────────────────────────

@app.get("/")
def root():
    return {"message": "Traza ML Service Running"}


@app.post("/process-report")
def analyze_report(report: Report):
    return process_report(report.model_dump())


@app.get("/analyze-all")
def analyze_all():
    reports = fetch_reports()
    results = []
    for r in reports:
        prediction = process_report({
            "category": r["incident_type"],
            "description": r["description"],
            "latitude": r.get("latitude", 0),
            "longitude": r.get("longitude", 0),
            "timestamp": r.get("timestamp", ""),
        })
        zone = classify_zone(r.get("latitude", 0), r.get("longitude", 0))
        results.append({
            "id": r["id"],
            "zone": zone,
            "latitude": r.get("latitude", 0),
            "longitude": r.get("longitude", 0),
            "severity": prediction["severity"],
            "confidence": prediction["confidence"],
            "risk_score": prediction["risk_score"],
        })
    return {"count": len(results), "results": results}


@app.get("/risk-analysis")
def risk_analysis():
    reports = fetch_reports()
    enriched_reports = []
    for r in reports:
        prediction = process_report({
            "category": r["incident_type"],
            "description": r["description"],
            "latitude": r.get("latitude", 0),
            "longitude": r.get("longitude", 0),
            "timestamp": r.get("timestamp", ""),
        })
        zone = classify_zone(r.get("latitude", 0), r.get("longitude", 0))
        enriched_reports.append({
            "severity": prediction["severity"],
            "zone": zone,
            "timestamp": r.get("timestamp", ""),
        })
    return analyze_risk(enriched_reports)