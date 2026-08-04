from typing import List
from app.database.connection import get_db


async def list_internal_marks(student_id: str) -> List[dict]:
    db = get_db()
    cursor = db.internal_marks.find({"student_id": student_id})
    return await cursor.to_list(length=500)


async def upsert_internal_mark(record: dict) -> None:
    db = get_db()
    await db.internal_marks.update_one(
        {"student_id": record["student_id"], "subject_code": record["subject_code"], "exam_type": record.get("exam_type")},
        {"$set": record},
        upsert=True,
    )
