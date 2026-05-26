from pydantic import BaseModel
from datetime import datetime


class ZoneSnapshot(BaseModel):
    """
    Representa una zona activa con su nivel de riesgo.
    Este es el contrato entre ML → Backend → Flutter.
    """
    zone_id: str          # slug único, ej: "parque_central"
    name: str             # nombre legible, ej: "Parque Central"
    latitude: float
    longitude: float
    radius: float         # metros
    risk_score: float     # 0.0 – 1.0
    report_count: int
    last_updated: datetime


class ZonesBroadcast(BaseModel):
    """
    Payload completo que se broadcastea por WebSocket
    y se sirve en GET /zones/active.
    """
    zones: list[ZoneSnapshot]
    computed_at: datetime