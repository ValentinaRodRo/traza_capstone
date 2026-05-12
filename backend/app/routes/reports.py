from fastapi import APIRouter
from app.schemas.report_schema import ReportCreate
from app.services.report_service import create_report

router = APIRouter(prefix="/reports", tags=["Reports"])


@router.post("/")
def create_new_report(report: ReportCreate):
    return create_report(report)