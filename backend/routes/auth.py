"""Prisma AI — Authentication routes.

Routes are thin doors. No business logic in routes/.
Delegates DB operations to db/postgres_service.py and hashing/JWT to auth/jwt.py.
"""

import asyncpg
from fastapi import APIRouter, HTTPException, Request, status
from pydantic import BaseModel

from auth import jwt
from db import postgres_service

router = APIRouter(prefix="/api/auth", tags=["auth"])


class RegisterRequest(BaseModel):
    email: str
    name: str
    password: str


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    token: str
    student_id: str
    name: str


@router.post("/register", response_model=TokenResponse)
async def register(request: Request, body: RegisterRequest):
    """Register a new student."""
    pool = request.app.state.pool
    hashed_password = jwt.hash_password(body.password)

    try:
        student = await postgres_service.create_student(
            pool, body.email, body.name, hashed_password
        )
    except asyncpg.UniqueViolationError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered",
        )

    student_id = student["id"]
    token = jwt.create_access_token(student_id)

    return TokenResponse(
        token=token,
        student_id=student_id,
        name=student["name"],
    )


@router.post("/login", response_model=TokenResponse)
async def login(request: Request, body: LoginRequest):
    """Log in an existing student."""
    pool = request.app.state.pool

    student = await postgres_service.get_student_by_email(pool, body.email)
    if not student:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    is_valid = jwt.verify_password(body.password, student["hashed_password"])
    if not is_valid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )

    student_id = student["id"]
    token = jwt.create_access_token(student_id)

    return TokenResponse(
        token=token,
        student_id=student_id,
        name=student["name"],
    )
