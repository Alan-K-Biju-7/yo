from bson import ObjectId
from fastapi import APIRouter, HTTPException, Response, status
from motor.motor_asyncio import AsyncIOMotorGridFSBucket

from app.database.connection import get_db

from app.routers import auth as auth_router
from app.routers import profile as profile_router
from app.routers import marks as marks_router
from app.routers import results as results_router
from app.routers import sync as sync_router
from app.routers import admin as admin_router
from app.routers import mobile as mobile_router

router = APIRouter(prefix="/api")


@router.get("/health", tags=["api"])
async def health_check() -> dict[str, str]:
    return {"status": "ok"}


@router.get("/files/{file_id}", tags=["files"])
async def download_file(file_id: str) -> Response:
    try:
        stream = await AsyncIOMotorGridFSBucket(get_db()).open_download_stream(
            ObjectId(file_id)
        )
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="File not found",
        ) from exc

    return Response(
        content=await stream.read(),
        media_type=(stream.metadata or {}).get("content_type", "application/pdf"),
        headers={"Content-Disposition": f'inline; filename="{stream.filename}"'},
    )


router.include_router(auth_router.router)
router.include_router(profile_router.router)
router.include_router(marks_router.router)
router.include_router(results_router.router)
router.include_router(sync_router.router)
router.include_router(admin_router.router)
router.include_router(mobile_router.router)
