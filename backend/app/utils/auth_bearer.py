from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Request, HTTPException
from jose import jwt, JWTError

SECRET_KEY = "traza_super_secret_key"
ALGORITHM = "HS256"


class JWTBearer(HTTPBearer):

    async def __call__(self, request: Request):

        credentials: HTTPAuthorizationCredentials = await super().__call__(request)

        if credentials:

            token = credentials.credentials

            try:

                payload = jwt.decode(
                    token,
                    SECRET_KEY,
                    algorithms=[ALGORITHM]
                )

                return payload

            except JWTError:
                raise HTTPException(
                    status_code=403,
                    detail="Token inválido"
                )

        raise HTTPException(
            status_code=403,
            detail="Token requerido"
        )