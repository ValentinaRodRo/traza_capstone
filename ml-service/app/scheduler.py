"""
scheduler.py — corre el ciclo ML cada 5 minutos y pushea la snapshot al backend.

Flujo:
  1. fetch_reports()          → reportes de la DB
  2. process_report() x N     → severity + risk_score por reporte
  3. _aggregate_zones()       → agrupa por zona, calcula centro y radio
  4. POST /internal/zones/update → backend broadcastea a todos los clientes WS
"""

import logging
import os
from collections import defaultdict
from datetime import datetime, timezone
from typing import Any

import httpx
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from app.data_loader import fetch_reports
from app.inference import process_report
from app.zone_classifier import classify_zone

logger = logging.getLogger(__name__)

BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8000")
ML_SERVICE_API_KEY = os.getenv("ML_SERVICE_API_KEY", "")
INTERVAL_MINUTES = int(os.getenv("ML_INTERVAL_MINUTES", "30"))

# Radio base por nivel de severidad (metros)
_RADIUS_BY_SEVERITY = {
    "bajo": 150,
    "medio": 220,
    "alto": 300,
    "critico": 400,
}


# ──────────────────────────────────────────────────────────────────────────────
#  Agregación de zonas
# ──────────────────────────────────────────────────────────────────────────────

def _aggregate_zones(enriched: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """
    Agrupa reportes por zona y calcula:
    - centro (promedio lat/lon)
    - radio (por severidad dominante)
    - risk_score promedio
    - conteo de reportes
    """
    buckets: dict[str, list[dict]] = defaultdict(list)

    for item in enriched:
        zone = item.get("zone", "desconocido")
        buckets[zone].append(item)

    zones = []
    for zone_name, items in buckets.items():
        lats = [i["latitude"] for i in items]
        lons = [i["longitude"] for i in items]
        scores = [i["risk_score"] for i in items]

        # Severidad dominante (la más frecuente)
        sev_counts: dict[str, int] = defaultdict(int)
        for i in items:
            sev_counts[i["severity"]] += 1
        dominant_sev = max(sev_counts, key=sev_counts.get)

        zones.append({
            "zone_id": zone_name.lower().replace(" ", "_"),
            "name": zone_name,
            "latitude": sum(lats) / len(lats),
            "longitude": sum(lons) / len(lons),
            "radius": _RADIUS_BY_SEVERITY.get(dominant_sev, 200),
            "risk_score": round(sum(scores) / len(scores), 2),
            "report_count": len(items),
            "last_updated": datetime.now(timezone.utc).isoformat(),
        })

    # Ordena de mayor a menor riesgo
    zones.sort(key=lambda z: z["risk_score"], reverse=True)
    return zones


# ──────────────────────────────────────────────────────────────────────────────
#  Tarea principal
# ──────────────────────────────────────────────────────────────────────────────

async def run_ml_cycle() -> None:
    """
    Corre el pipeline completo y envía la snapshot al backend.
    Si algo falla, loggea y sigue — no mata el scheduler.
    """
    logger.info("▶ Iniciando ciclo ML...")

    try:
        reports = fetch_reports()
        if not reports:
            logger.warning("Sin reportes disponibles, se omite el ciclo.")
            return

        enriched = []
        for r in reports:
            try:
                prediction = process_report({
                    "category": r["incident_type"],
                    "description": r["description"],
                    "latitude": r.get("latitude", 0.0),
                    "longitude": r.get("longitude", 0.0),
                    "timestamp": r.get("timestamp", ""),
                })
                enriched.append({
                    **prediction,
                    "latitude": r.get("latitude", 0.0),
                    "longitude": r.get("longitude", 0.0),
                })
            except Exception as exc:
                logger.warning("Error procesando reporte %s: %s", r.get("id"), exc)

        if not enriched:
            logger.warning("Ningún reporte se procesó correctamente.")
            return

        zones = _aggregate_zones(enriched)
        payload = {
            "zones": zones,
            "computed_at": datetime.now(timezone.utc).isoformat(),
        }

        async with httpx.AsyncClient(timeout=10) as client:
            resp = await client.post(
                f"{BACKEND_URL}/internal/zones/update",
                json=payload,
                headers={"X-Internal-Key": ML_SERVICE_API_KEY},
            )
            resp.raise_for_status()

        logger.info("✓ Ciclo ML completado. Zonas enviadas: %d", len(zones))

    except Exception as exc:
        logger.error("✗ Error en ciclo ML: %s", exc, exc_info=True)


# ──────────────────────────────────────────────────────────────────────────────
#  Scheduler
# ──────────────────────────────────────────────────────────────────────────────

def create_scheduler() -> AsyncIOScheduler:
    scheduler = AsyncIOScheduler()
    scheduler.add_job(
        run_ml_cycle,
        trigger="interval",
        minutes=INTERVAL_MINUTES,
        id="ml_cycle",
        replace_existing=True,
        max_instances=1,        # nunca dos ciclos en paralelo
    )
    return scheduler