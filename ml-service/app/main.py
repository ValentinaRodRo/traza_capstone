from fastapi import FastAPI
from pydantic import BaseModel

from inference import process_report
from data_loader import fetch_reports

from zone_classifier import classify_zone

app = FastAPI()

class Report(BaseModel):

    category: str
    description: str
    latitude: float
    longitude: float
    timestamp: str


@app.get("/")
def root():

    return {
        "message":
        "Traza ML Service Running"
    }


@app.post("/process-report")
def analyze_report(report: Report):

    return process_report(
        report.model_dump()
    )


@app.get("/analyze-all")
def analyze_all():

    reports = fetch_reports()

    results = []

    for r in reports:

        prediction = process_report({
            "category":
                r["incident_type"],

            "description":
                r["description"],

            "latitude":
                r.get("latitude", 0),

            "longitude":
                r.get("longitude", 0),

            "timestamp":
                r.get("timestamp", "")
        })

        zone = classify_zone(
            r.get("latitude", 0),
            r.get("longitude", 0)
        )

        results.append({

            "id":
                r["id"],

            "zone":
                zone,

            "latitude":
                r.get("latitude", 0),

            "longitude":
                r.get("longitude", 0),

            "severity":
                prediction["severity"],

            "confidence":
                prediction["confidence"],

            "risk_score":
                prediction["risk_score"]
        })

    return {
        "count":
            len(results),

        "results":
            results,

    }