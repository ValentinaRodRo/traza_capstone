from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.report_schema import ReportCreate
from app.services.report_service import create_report, get_reports

router = APIRouter(prefix="/reports", tags=["Reports"])


@router.post("/")
def create_new_report(report: ReportCreate, db: Session = Depends(get_db)):
    return create_report(db, report)


@router.get("/")
def list_reports(db: Session = Depends(get_db)):
    return get_reports(db)