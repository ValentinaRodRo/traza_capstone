from sqlalchemy.orm import Session
from app.models.report_model import Report
from datetime import datetime
from app.models.notification_model import Notification
from app.models.user_model import User
from app.utils.report_status import ReportStatus
from app.models.report_history_model import ReportHistory
import uuid


def generate_tracking_code(db: Session):
    year = datetime.utcnow().year
    unique_part = uuid.uuid4().hex[:8].upper()
    return f"CHI-{year}-{unique_part}"


def create_report(
    db: Session,
    data,
    user_id: int
):
    report = Report(
        tracking_code=generate_tracking_code(db),
        incident_type=data.incident_type,
        description=data.description,
        latitude=data.latitude,
        longitude=data.longitude,
        anonymous=data.anonymous,
        status=ReportStatus.RECEIVED.value,
        user_id=user_id
    )

    db.add(report)
    db.commit()
    db.refresh(report)
    notification = Notification(
        user_id=user_id,
        message=f"Tu reporte {report.tracking_code} fue creado correctamente"
    )

    db.add(notification)

    authorities = db.query(User).filter(
        User.role == "authority"
    ).all()

    for authority in authorities:

        admin_notification = Notification(
            user_id=authority.id,
            message=f"Nuevo reporte de {report.incident_type} creado con código {report.tracking_code}"
        )

        db.add(admin_notification)

    db.commit()

    return report


def get_reports(
    db: Session,
    status: str = None,
    incident_type: str = None
):

    query = db.query(Report)

    if status:
        query = query.filter(
            Report.status == status
        )

    if incident_type:
        query = query.filter(
            Report.incident_type == incident_type
        )

    reports = query.all()

    response = []

    for report in reports:

        report_data = {
            "tracking_code": report.tracking_code,
            "incident_type": report.incident_type,
            "description": report.description,
            "latitude": report.latitude,
            "longitude": report.longitude,
            "status": report.status,
            "anonymous": report.anonymous,
            "created_at": report.created_at
        }

        if not report.anonymous:

            user = db.query(User).filter(
                User.id == report.user_id
            ).first()

            report_data["citizen_name"] = user.name
            report_data["citizen_email"] = user.email

        response.append(report_data)

    return response

def get_user_reports(
    db: Session,
    user_id: int
):
    return db.query(Report).filter(
        Report.user_id == user_id
    ).all()

def update_report_status(
    db: Session,
    tracking_code: str,
    status: str,
    comment: str,
    authority_id: int
):
    report = db.query(Report).filter(
        Report.tracking_code == tracking_code
    ).first()

    if not report:
        return None

    report.status = status

    notification = Notification(
        user_id=report.user_id,
        message=f"Tu reporte {report.tracking_code} cambió a estado {status}. Comentario: {comment}"
    )

    history = ReportHistory(
        report_id=report.id,
        status=status,
        comment=comment,
        created_by=authority_id
    )

    db.add(history)

    db.add(notification)

    db.commit()
    db.refresh(report)

    return report

def delete_report(db: Session, report_id: int):

    report = db.query(Report).filter(Report.id == report_id).first()

    if not report:
        return None

    db.delete(report)
    db.commit()

    return True

def get_report_history(
    db: Session,
    tracking_code: str
):
    report = db.query(Report).filter(
        Report.tracking_code == tracking_code
    ).first()

    if not report:
        return None

    history = db.query(ReportHistory).filter(
        ReportHistory.report_id == report.id
    ).all()

    return history