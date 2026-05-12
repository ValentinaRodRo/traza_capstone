from fastapi import FastAPI
from app.routes.reports import router as reports_router

app = FastAPI()

app.include_router(reports_router)


@app.get("/")
def home():
    return {"message": "TRAZA backend funcionando"}