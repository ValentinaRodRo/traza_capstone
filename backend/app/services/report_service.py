from sqlalchemy.orm import Session
from app.models.report_model import Report
from datetime import datetime
from app.models.notification_model import Notification
from app.models.user_model import User


def generate_tracking_code(db: Session):

    year = datetime.utcnow().year

    count = db.query(Report).count() + 1

    return f"CHI-{year}-{count:04d}"


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
        status="recibido",
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
        query = query.filter(Report.status == status)

    if incident_type:
        query = query.filter(
            Report.incident_type == incident_type
        )

    return query.all()

def get_user_reports(
    db: Session,
    user_id: int
):
    return db.query(Report).filter(
        Report.user_id == user_id
    ).all()

def update_report_status(db: Session, report_id: int, status: str):
    report = db.query(Report).filter(Report.id == report_id).first()

    if not report:
        return None

    report.status = status

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