from fastapi import APIRouter, Depends, Security
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.notification_model import Notification
from app.utils.auth_bearer import JWTBearer

router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"]
)


@router.get("/")
def get_notifications(
    db: Session = Depends(get_db),
    payload=Security(JWTBearer())
):

    print(payload)

    notifications = db.query(Notification).filter(
        Notification.user_id == payload["user_id"]
    ).all()

    return notifications