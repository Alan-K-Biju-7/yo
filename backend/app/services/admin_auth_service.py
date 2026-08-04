import bcrypt
from datetime import datetime, timedelta
from jose import JWTError, jwt
from typing import Optional
from app.repositories.admin import AdminRepository
from app.database.connection import get_db
import os

ALGORITHM = "HS256"
ADMIN_SECRET_KEY = os.getenv("ADMIN_SECRET_KEY", "your-admin-secret-key-change-this")
ADMIN_ACCESS_TOKEN_EXPIRE_MINUTES = 1440  # 24 hours


def hash_password(password: str) -> str:
    return bcrypt.hashpw(
        password.encode("utf-8"),
        bcrypt.gensalt(),
    ).decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return bcrypt.checkpw(
            plain_password.encode("utf-8"),
            hashed_password.encode("utf-8"),
        )
    except (TypeError, ValueError):
        return False


def create_admin_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ADMIN_ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, ADMIN_SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_admin_token(token: str) -> Optional[str]:
    try:
        payload = jwt.decode(token, ADMIN_SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            return None
        return username
    except JWTError:
        return None


async def authenticate_admin(username: str, password: str) -> Optional[dict]:
    db = get_db()
    repo = AdminRepository(db)
    admin = await repo.get_admin_by_username(username)
    
    if not admin:
        return None
    
    if not verify_password(password, admin.get("password_hash", "")):
        return None
    
    return admin


async def create_admin_user(username: str, password: str, name: str) -> Optional[str]:
    db = get_db()
    repo = AdminRepository(db)
    password_hash = hash_password(password)
    return await repo.create_admin(username, password_hash, name)
