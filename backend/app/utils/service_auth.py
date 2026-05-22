from fastapi import Header, HTTPException

from app.config import ML_SERVICE_API_KEY


def verify_ml_service(
    x_api_key: str = Header(None)
):

    if x_api_key != ML_SERVICE_API_KEY:

        raise HTTPException(
            status_code=401,
            detail="Unauthorized service"
        )