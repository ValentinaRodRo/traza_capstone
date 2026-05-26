from pydantic import BaseModel, ConfigDict, field_serializer
from datetime import datetime
from typing import Optional


class ReportCreate(BaseModel):
    incident_type: str
    description: str
    latitude: float
    longitude: float
    anonymous: bool = True


class ReportUpdate(BaseModel):
    status: str
    comment: str


class ReportResponse(BaseModel):
    tracking_code: str
    incident_type: str
    description: str
    latitude: float
    longitude: float
    anonymous: bool
    status: str
    created_at: datetime
    officer_note: Optional[str] = None  # último comentario de autoridad

    model_config = ConfigDict(from_attributes=True)

    @field_serializer('created_at')
    def serialize_dt(self, dt: datetime) -> str:
        return dt.isoformat()