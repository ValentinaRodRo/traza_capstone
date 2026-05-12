from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.report_schema import ReportCreate
from app.services.report_service import create_report, get_reports
from app.schemas.report_schema import ReportUpdate
from app.services.report_service import update_report_status
from app.models.report_model import Report

router = APIRouter(prefix="/reports", tags=["Reports"])


@router.post("/")
def create_new_report(report: ReportCreate, db: Session = Depends(get_db)):
    return create_report(db, report)


@router.get("/")
def list_reports(
    status: str = None,
    incident_type: str = None,
    db: Session = Depends(get_db)
):
    return get_reports(
        db,
        status,
        incident_type
    )

@router.put("/{report_id}")
def update_report(
    report_id: int,
    report_data: ReportUpdate,
    db: Session = Depends(get_db)
):
    report = update_report_status(
        db,
        report_id,
        report_data.status
    )

    if not report:
        return {"error": "Reporte no encontrado"}

    return report

@router.delete("/{report_id}")
def delete_report(report_id: int, db: Session = Depends(get_db)):

    report = db.query(Report).filter(Report.id == report_id).first()

    if not report:
        return {"error": "Reporte no encontrado"}

    db.delete(report)
    db.commit()

    return {"message": "Reporte eliminado correctamente"}