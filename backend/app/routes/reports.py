from fastapi import APIRouter, Depends, Security
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.report_schema import ReportCreate, ReportUpdate
from app.services.report_service import (
    create_report,
    get_reports,
    get_user_reports,
    update_report_status
)
from app.models.report_model import Report
from app.utils.auth_bearer import JWTBearer

router = APIRouter(
    prefix="/reports",
    tags=["Reports"]
)


@router.post("/")
def create_new_report(
    report: ReportCreate,
    db: Session = Depends(get_db),
    payload=Security(JWTBearer())
):
    return create_report(
    db,
    report,
    payload["user_id"]
)


@router.get("/")
def list_reports(
    status: str = None,
    incident_type: str = None,
    db: Session = Depends(get_db),
    payload=Security(JWTBearer())
):

    if payload["role"] != "authority":
        return {"error": "No autorizado"}

    return get_reports(
        db,
        status,
        incident_type
    )

@router.get("/my-reports")
def my_reports(
    db: Session = Depends(get_db),
    payload=Security(JWTBearer())
):
    return get_user_reports(
        db,
        payload["user_id"]
    )


@router.put("/{tracking_code}/status")
def update_report(
    tracking_code: str,
    report_data: ReportUpdate,
    db: Session = Depends(get_db),
    payload=Security(JWTBearer())
):

    if payload["role"] != "authority":
        return {"error": "No autorizado"}

    report = update_report_status(
        db,
        tracking_code,
        report_data.status
    )

    if not report:
        return {"error": "Reporte no encontrado"}

    return report


@router.delete("/{report_id}")
def delete_report(
    report_id: int,
    db: Session = Depends(get_db),
    payload=Security(JWTBearer())
):

    if payload["role"] != "authority":
        return {"error": "No autorizado"}

    report = db.query(Report).filter(
        Report.id == report_id
    ).first()

    if not report:
        return {"error": "Reporte no encontrado"}

    db.delete(report)
    db.commit()

    return {
        "message": "Reporte eliminado correctamente"
    }