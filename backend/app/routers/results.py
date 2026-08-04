from fastapi import APIRouter, HTTPException
from app.repositories import results as results_repo

router = APIRouter(prefix="/results", tags=["results"])


@router.get("/")
async def get_results(student_id: str):
    if not student_id:
        raise HTTPException(status_code=400, detail="student_id required")
    rows = await results_repo.list_results(student_id)
    return {"items": rows}
