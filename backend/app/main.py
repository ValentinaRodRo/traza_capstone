import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from app.models.notification_model import Notification      # noqa: F401
from app.models.report_history_model import ReportHistory   # noqa: F401
from app.models.report_model import Report                  # noqa: F401
from app.models.user_model import User                      # noqa: F401
from app.routes.auth import router as auth_router
from app.routes.notifications import router as notifications_router
from app.routes.reports import router as reports_router
from app.routes.zones import router as zones_router         # ← nuevo

logging.basicConfig(level=logging.INFO)

app = FastAPI(title="Traza API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

# ── Routers ────────────────────────────────────────────────────────────────────
app.include_router(reports_router)
app.include_router(auth_router)
app.include_router(notifications_router)
app.include_router(zones_router)                             # ← nuevo


@app.get("/")
def home():
    return {"message": "TRAZA backend funcionando"}