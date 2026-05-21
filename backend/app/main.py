from fastapi import FastAPI
from app.routes.reports import router as reports_router
from app.database import engine, Base
from app.models.report_model import Report
from fastapi.middleware.cors import CORSMiddleware
from app.models.user_model import User
from app.models.notification_model import Notification
from app.routes.auth import router as auth_router
from app.routes.notifications import router as notifications_router
from app.models.report_history_model import ReportHistory

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

app.include_router(reports_router)
app.include_router(auth_router)
app.include_router(notifications_router)


@app.get("/")
def home():
    return {"message": "TRAZA backend funcionando"}