"""Prisma AI — JWT authentication utilities.

Handles token creation, validation, and password hashing.
No database calls. No route definitions.
"""

import os
from datetime import datetime, timedelta, timezone

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwt
from passlib.context import CryptContext

SECRET_KEY = os.getenv("SECRET_KEY", "dev-secret")
ALGORITHM = "HS256"
TOKEN_EXPIRE_DAYS = 7

_pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
_bearer_scheme = HTTPBearer()


# ---------------------------------------------------------------------------
# Token
# ---------------------------------------------------------------------------
def create_access_token(student_id: str) -> str:
    """Create a signed JWT with ``sub`` = *student_id* and 7-day expiry."""
    payload = {
        "sub": student_id,
        "exp": datetime.now(timezone.utc) + timedelta(days=TOKEN_EXPIRE_DAYS),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


async def get_current_student(
    token: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
) -> str:
    """FastAPI dependency — decode JWT and return ``student_id``.

    Raises:
        HTTPException 401: If the token is invalid or expired.
    """
    try:
        payload = jwt.decode(token.credentials, SECRET_KEY, algorithms=[ALGORITHM])
        student_id: str | None = payload.get("sub")
        if student_id is None:
            raise JWTError("Missing 'sub' claim")
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return student_id


# ---------------------------------------------------------------------------
# Password hashing
# ---------------------------------------------------------------------------
def hash_password(password: str) -> str:
    """Return a bcrypt hash of *password*."""
    return _pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    """Return ``True`` if *plain* matches the bcrypt *hashed* value."""
    return _pwd_context.verify(plain, hashed)
