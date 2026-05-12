from fastapi import FastAPI
from app.routes.reports import router as reports_router
from app.database import engine, Base
from app.models.report_model import Report

app = FastAPI()
Base.metadata.create_all(bind=engine)

app.include_router(reports_router)


@app.get("/")
def home():
    return {"message": "TRAZA backend funcionando"}