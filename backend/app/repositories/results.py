from typing import List
from app.database.connection import get_db


async def list_results(student_id: str) -> List[dict]:
    db = get_db()
    cursor = db.results.find({"student_id": student_id})
    return await cursor.to_list(length=500)


async def upsert_result(record: dict) -> None:
    db = get_db()
    await db.results.update_one({"student_id": record["student_id"], "subject_code": record["subject_code"]}, {"$set": record}, upsert=True)
