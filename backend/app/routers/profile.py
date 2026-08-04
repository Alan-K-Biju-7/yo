from fastapi import APIRouter, Depends, HTTPException
from app.database.connection import get_db
from app.schemas.models import StudentProfile

router = APIRouter(prefix="/profile", tags=["profile"])


@router.get("/me", response_model=StudentProfile)
async def get_my_profile(student_id: str | None = None):
    # In a real app you'd derive student_id from the authenticated user token.
    if not student_id:
        raise HTTPException(status_code=400, detail="student_id is required as query parameter for now")
    db = get_db()
    doc = await db.students.find_one({"_id": student_id})
    if not doc:
        raise HTTPException(status_code=404, detail="student not found")
    # map _id to student_id for Pydantic model
    doc["_id"] = doc.get("_id")
    return doc
