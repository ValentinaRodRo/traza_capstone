from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime
from datetime import datetime

from app.database import Base
from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey

class Report(Base):
    __tablename__ = "reports"

    id = Column(Integer, primary_key=True, index=True)
    tracking_code = Column(String, unique=True, index=True)
    
    incident_type = Column(String)
    description = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    anonymous = Column(Boolean)
    status = Column(String)

    created_at = Column(DateTime, default=datetime.utcnow)