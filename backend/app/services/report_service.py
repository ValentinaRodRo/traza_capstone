from sqlalchemy.orm import Session
from app.models.report_model import Report


def create_report(db: Session, data):
    report = Report(
        incident_type=data.incident_type,
        description=data.description,
        latitude=data.latitude,
        longitude=data.longitude,
        anonymous=data.anonymous,
        status="recibido"
    )

    db.add(report)
    db.commit()
    db.refresh(report)

    return report


def get_reports(db: Session):
    return db.query(Report).all()

def update_report_status(db: Session, report_id: int, status: str):
    report = db.query(Report).filter(Report.id == report_id).first()

    if not report:
        return None

    report.status = status

    db.commit()
    db.refresh(report)

    return report