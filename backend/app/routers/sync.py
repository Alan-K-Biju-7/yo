from fastapi import APIRouter, Depends
from app.services.sync_service import sync_all
from app.database.connection import get_db

router = APIRouter(prefix="/sync", tags=["sync"])


@router.post("/")
async def run_sync():
    db = get_db()
    result = await sync_all(db)
    return result
