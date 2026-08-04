from fastapi import APIRouter

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


router.include_router(auth_router.router)
router.include_router(profile_router.router)
router.include_router(marks_router.router)
router.include_router(results_router.router)
router.include_router(sync_router.router)
router.include_router(admin_router.router)
router.include_router(mobile_router.router)
