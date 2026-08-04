from typing import Optional
from app.database.connection import get_db


async def get_student_by_id(student_id: str) -> Optional[dict]:
    db = get_db()
    doc = await db.students.find_one({"_id": student_id})
    return doc


async def upsert_student(student: dict) -> None:
    db = get_db()
    await db.students.update_one({"_id": student["_id"]}, {"$set": student}, upsert=True)
