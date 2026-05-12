reports = []


def create_report(data):
    report = {
        "id": len(reports) + 1,
        "incident_type": data.incident_type,
        "description": data.description,
        "latitude": data.latitude,
        "longitude": data.longitude,
        "anonymous": data.anonymous,
        "status": "recibido"
    }

    reports.append(report)

    return report

def get_reports(db: Session):
    return db.query(Report).all()