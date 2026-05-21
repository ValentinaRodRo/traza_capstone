from pydantic import BaseModel, ConfigDict
from datetime import datetime


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

    model_config = ConfigDict(
        from_attributes=True
    )