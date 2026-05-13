from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.user_schema import UserCreate, UserLogin
from app.services.auth_service import create_user, authenticate_user
from app.utils.jwt_handler import create_access_token

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):

    new_user = create_user(
        db,
        user.email,
        user.password
    )

    return {
        "message": "Usuario creado",
        "user_id": new_user.id
    }


@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):

    authenticated_user = authenticate_user(
        db,
        user.email,
        user.password
    )

    if not authenticated_user:
        return {"error": "Credenciales incorrectas"}

    token = create_access_token(
        data={
            "user_id": authenticated_user.id,
            "email": authenticated_user.email,
            "role": authenticated_user.role
        }
    )

    return {
        "access_token": token,
        "token_type": "bearer"
    }