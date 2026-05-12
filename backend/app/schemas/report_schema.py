from pydantic import BaseModel


class ReportCreate(BaseModel):
    incident_type: str
    description: str
    latitude: float
    longitude: float
    anonymous: bool = True