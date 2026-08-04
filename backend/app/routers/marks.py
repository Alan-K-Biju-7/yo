from fastapi import APIRouter, HTTPException
from app.repositories import internal_marks as internal_repo

router = APIRouter(prefix="/internal-marks", tags=["internal-marks"])


@router.get("/")
async def get_internal_marks(student_id: str):
    if not student_id:
        raise HTTPException(status_code=400, detail="student_id required")
    rows = await internal_repo.list_internal_marks(student_id)
    return {"items": rows}
