from typing import List
from app.database.connection import get_db


async def list_subjects(filter: dict | None = None) -> List[dict]:
    db = get_db()
    cursor = db.subjects.find(filter or {})
    return await cursor.to_list(length=200)


async def upsert_subject(subject: dict) -> None:
    db = get_db()
    await db.subjects.update_one({"code": subject["code"]}, {"$set": subject}, upsert=True)
