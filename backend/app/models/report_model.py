from sqlalchemy import Column, Integer, String, Float, Boolean
from app.database import Base


class Report(Base):
    __tablename__ = "reports"

    id = Column(Integer, primary_key=True, index=True)
    incident_type = Column(String)
    description = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    anonymous = Column(Boolean)
    status = Column(String)